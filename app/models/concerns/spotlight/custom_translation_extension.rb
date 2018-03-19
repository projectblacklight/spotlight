module Spotlight
  ##
  # Module that extends I18n::Backend::ActiveRecord::Translation to provide
  # additional Spotlight behavior, such as exhibit specific Translations
  module CustomTranslationExtension
    extend ActiveSupport::Concern

    included do
      default_scope { where(exhibit: current_exhibit) }
      belongs_to :exhibit, class_name: 'Spotlight::Exhibit', inverse_of: :translations

      before_validation do
        mark_for_destruction if value.blank?
      end
    end

    class_methods do
      def current_exhibit
        Thread.current[:current_exhibit]
      end

      def current_exhibit=(exhibit)
        Thread.current[:current_exhibit] = exhibit
      end
    end
  end
end
