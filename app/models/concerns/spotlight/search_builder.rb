# frozen_string_literal: true

module Spotlight
  # Enforce exhibit visibility for index queries
  module SearchBuilder
    extend ActiveSupport::Concern

    include Spotlight::AccessControlsEnforcementSearchBuilder
    include Spotlight::BrowseCategorySearchBuilder
  end
end
