module ControllerLevelHelpers
  def search_state
    @search_state ||= Blacklight::SearchState.new(params, blacklight_config)
  end

  def blacklight_configuration_context
    @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(controller)
  end

  def initialize_controller_helpers(helper)
    helper.extend ControllerLevelHelpers
  end
end
