# frozen_string_literal: true

module Spotlight
  module TestViewHelpers
    extend ActiveSupport::Concern

    included do
      before do
        view.send(:extend, Spotlight::RenderingHelper)
        view.send(:extend, Spotlight::MainAppHelpers)
        view.send(:extend, Spotlight::CrudLinkHelpers)
        view.send(:extend, Spotlight::TitleHelper)
        view.send(:extend, Spotlight::NavbarHelper)
        view.send(:extend, Spotlight::CropHelper)
        view.send(:extend, Blacklight::ComponentHelperBehavior)
        view.send(:extend, BreadcrumbsOnRails::ActionController::HelperMethods)
      end
    end
  end
end
