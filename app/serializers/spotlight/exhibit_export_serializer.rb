require 'roar/decorator'
require 'roar/json'
module Spotlight
  class ConfigurationRepresenter < Roar::Decorator
    include Roar::JSON

    (Spotlight::BlacklightConfiguration.attribute_names - ['id', 'exhibit_id']).each do |prop|
      property prop
    end
  end

  class ExhibitExportSerializer < Roar::Decorator
    include Roar::JSON

    (Spotlight::Exhibit.attribute_names - ['id', 'default', 'slug']).each do |prop|
      property prop
    end

    collection :searches, class: Spotlight::Search do
      (Spotlight::Search.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :about_pages, class: Spotlight::AboutPage, decorator: PageRepresenter

    collection :feature_pages, getter: lambda { |opts| feature_pages.at_top_level }, class: Spotlight::FeaturePage, decorator: NestedPageRepresenter

    property :home_page, class: Spotlight::HomePage, decorator: PageRepresenter

    property :blacklight_configuration, class: Spotlight::BlacklightConfiguration, decorator: ConfigurationRepresenter

    collection :custom_fields, class: Spotlight::CustomField do
      (Spotlight::CustomField.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :contacts, class: Spotlight::Contact do
      (Spotlight::Contact.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :contact_emails, class: Spotlight::ContactEmail do
      (Spotlight::ContactEmail.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :solr_document_sidecars, class: Spotlight::SolrDocumentSidecar do
      (Spotlight::SolrDocumentSidecar.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :owned_taggings, class: ActsAsTaggableOn::Tagging do
      property :taggable_id
      property :taggable_type
      property :context
      property :tag, exec_context: :decorator

      def tag
        represented.tag.name
      end

      def tag= tag
        represented.tag = ActsAsTaggableOn::Tag.find_or_create_by name: tag
      end
    end

    collection :attachments, class: Spotlight::Attachment do
      (Spotlight::Attachment.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end

    collection :resources, class: Spotlight::Resource do
      (Spotlight::Resource.attribute_names - ['id', 'slug', 'exhibit_id']).each do |prop|
        property prop
      end
    end
  end
end
