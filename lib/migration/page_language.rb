module Migration
  ##
  # This migration sets the Spotlight::Page locale to the I18n.default_locale.
  # Needed for migrating Exhibits to internationalization work.
  class PageLanguage
    def self.run
      new.run
    end

    def initialize; end

    def run
      migrate_pages
    end

    private

    def migrate_pages
      FriendlyId::Slug.where(sluggable_type: 'Spotlight::Page').find_each do |slug|
        unless /locale:\w+/ =~ slug.scope
          slug.scope += ",locale:#{I18n.default_locale}"
          slug.save
        end
      end
    end
  end
end
