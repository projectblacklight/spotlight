# frozen_string_literal: true

module Controllers
  module EngineHelpers
    def main_app
      Rails.application.class.routes.url_helpers
    end
  end
end
