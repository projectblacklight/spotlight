# frozen_string_literal: true

module Spotlight
  # Component to render breadcrumbs
  class BreadcrumbsComponent < ViewComponent::Base
    attr_reader :breadcrumbs

    def initialize(breadcrumbs: [])
      @breadcrumbs = breadcrumbs
      super()
    end

    def render?
      !helpers.resource_masthead? && breadcrumbs.present?
    end

    def path(path)
      helpers.url_for(path)
    end
  end
end
