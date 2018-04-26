module Spotlight
  # Mixin for adding translatable ActiveRecord accessors
  module Translatables
    extend ActiveSupport::Concern

    class_methods do
      def translates(*attr_names)
        attr_names.map(&:to_sym)
        attr_names.map(&method(:define_translated_attr_reader))
      end

      ##
      # Set up a reader for the specified attribute that uses the I18n backend,
      # and defaults to the ActiveRecord value
      def define_translated_attr_reader(attr_name)
        define_method(:"#{attr_name}") do
          I18n.translate(attr_name, scope: slug, default: attr_translation(attr_name))
        end
      end
    end

    private

    ##
    # Will return the default ActiveRecord value for the value
    def attr_translation(attr_name)
      self[attr_name]
    end
  end
end
