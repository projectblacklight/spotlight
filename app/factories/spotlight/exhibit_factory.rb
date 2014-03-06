module Spotlight
  class ExhibitFactory
    
    class << self
      def create(exhibit)
        if exhibit.save
          after_create(exhibit)
        end
      end

      def create!(exhibit)
        exhibit.save!
        after_create(exhibit)
      end

      # Find or create the default exhibit
      def default
        Spotlight::Exhibit.find_or_initialize_by(default: true) do |e|
          e.title = 'Default exhibit'.freeze
          create(e)
        end
      end

      def import exhibit, hash
        # remove the default browse category -- it might be in the import
        # and we don't want to have a conflicting slug

        if exhibit.persisted?
          exhibit.searches.where(title: "Browse All Exhibit Items").destroy_all
          exhibit.reload
        end
        exhibit.update hash
      end

      private 

      def after_create(exhibit)
        initialize_config(exhibit)
        initialize_browse(exhibit)
        add_default_home_page(exhibit)
      end

      def add_default_home_page(exhibit)
        Spotlight::HomePage.create(exhibit: exhibit)
      end

      def initialize_config(exhibit)
        exhibit.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
      end

      def initialize_browse(exhibit)
        return unless exhibit.searches.blank?

        exhibit.searches.create title: "Browse All Exhibit Items",
          short_description: "Search results for all items in this exhibit",
          long_description: "All items in this exhibit"
      end
    end
  end
end
