module Spotlight
  module TestViewHelpers
    extend ActiveSupport::Concern

    included do
      before do
        view.send(:extend, Spotlight::CrudLinkHelpers)
        view.send(:extend, Spotlight::TitleHelper)
      end
    end
  end
end
