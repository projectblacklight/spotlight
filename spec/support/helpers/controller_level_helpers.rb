# frozen_string_literal: true

module ControllerLevelHelpers
  def search_state
    @search_state ||= Blacklight::SearchState.new(params, blacklight_config)
  end

  def current_site
    Spotlight::Site.instance
  end

  def blacklight_configuration_context
    @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(controller)
  end

  def initialize_controller_helpers(helper)
    helper.extend ControllerLevelHelpers
    initialize_routing_helpers(helper)
  end

  def initialize_routing_helpers(helper)
    helper.class.include ::Rails.application.routes.url_helpers
    helper.class.include ::Rails.application.routes.mounted_helpers if ::Rails.application.routes.respond_to?(:mounted_helpers)
  end
end
