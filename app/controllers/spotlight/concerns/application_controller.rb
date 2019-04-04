# frozen_string_literal: true

require 'spotlight'

module Spotlight
  module Concerns
    # Inherit from the host app's ApplicationController
    # This will configure e.g. the layout used by the host
    module ApplicationController
      extend ActiveSupport::Concern
      include Spotlight::Controller

      included do
        layout 'spotlight/spotlight'

        helper Spotlight::ApplicationHelper

        rescue_from CanCan::AccessDenied do |exception|
          if current_exhibit && !can?(:read, current_exhibit)
            # Try to authenticate the user
            authenticate_user!

            # If that fails (and we end up back here), offer a 404 error instead
            raise ActionController::RoutingError, 'Not Found'
          else
            redirect_to main_app.root_url, alert: exception.message
          end
        end
      end

      def enabled_in_spotlight_view_type_configuration?(config, *args)
        if config.respond_to?(:original) && !blacklight_configuration_context.evaluate_if_unless_configuration(config.original, *args)
          false
        elsif current_exhibit.nil? || is_a?(Spotlight::PagesController)
          true
        else
          current_exhibit.blacklight_configuration.document_index_view_types.include? config.key.to_s
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def field_enabled?(field, *args)
        if !field.enabled
          false
        elsif field.respond_to?(:original) && !blacklight_configuration_context.evaluate_if_unless_configuration(field.original, *args)
          false
        elsif field.is_a?(Blacklight::Configuration::SortField) || field.is_a?(Blacklight::Configuration::SearchField)
          field.enabled
        elsif field.is_a?(Blacklight::Configuration::FacetField) || (is_a?(Blacklight::Catalog) && %w(edit show).include?(action_name))
          field.show
        else
          field.send(document_index_view_type)
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength

      private

      ##
      # Get the current "view type" (and ensure it is a valid type)
      #
      # @param [Hash] the query parameters to check
      # @return [Symbol]
      def document_index_view_type
        view_param = params[:view]
        view_param ||= session[:preferred_view]
        if view_param && document_index_views.key?(view_param.to_sym)
          view_param.to_sym
        else
          default_document_index_view_type
        end
      end

      def document_index_views
        blacklight_config.view.select do |_k, config|
          blacklight_configuration_context.evaluate_if_unless_configuration config
        end
      end

      ##
      # Get the default index view type
      def default_document_index_view_type
        document_index_views.select { |_k, config| config.respond_to?(:default) && config.default }.keys.first || document_index_views.keys.first
      end
    end
  end
end
