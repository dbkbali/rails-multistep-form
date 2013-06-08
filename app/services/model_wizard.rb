class ModelWizard
  attr_reader :object

  def initialize(object_class, session, params = nil)
    @object_class = object_class
    @session = session
    @params = params
    @session_params = "#{object_class.name.underscore}_params".to_sym
  end

  def start(object = nil)
    @session[@session_params] = {}
    @object = object || @object_class.new(@session[@session_params])
    @object.current_step = 0
    self
  end

  def process(param_name, object = nil)
    @session[@session_params].deep_merge!(@params[param_name]) if @params[param_name]
    if object.nil?
      @object = @object_class.new(@session[@session_params])
    else
      @object = object
      @object.assign_attributes(@session[@session_params])
    end
    self
  end

  def save
    saved = false
    if @params[:back_button]
      @object.step_back
    elsif @object.current_step_valid?
      if @object.last_step?
        if @object.all_steps_valid?
          saved = @object.save
          @session[@session_param] = nil
        end
      else
        @object.step_forward
      end
    end
    saved
  end

end