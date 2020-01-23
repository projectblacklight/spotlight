# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require 'base64'
require 'tempfile'

module Spotlight
  ##
  # Serialize the Spotlight::BlacklightConfiguration
  class ConfigurationRepresenter < Roar::Decorator
    include Roar::JSON

    (Spotlight::BlacklightConfiguration.attribute_names - %w[id exhibit_id]).each do |prop|
      property prop
    end

    property :skip_default_configuration, exec_context: :decorator

    def skip_default_configuration
      true
    end

    delegate :skip_default_configuration=, to: :represented
  end

  ##
  # Serialize an exhibit with all the data needed to reconstruct it
  # in a different environment
  class ExhibitExportSerializer < Roar::Decorator
    def self.config?(config)
      lambda do |**_args|
        Spotlight::Engine.config.exports[config]
      end
    end

    include Roar::JSON

    (Spotlight::Exhibit.attribute_names - %w[id slug masthead_id thumbnail_id]).each do |prop|
      property prop, if: config?(:config)
    end

    property :theme, if: config?(:config), setter: lambda { |fragment:, represented:, **|
      represented.theme = fragment if Spotlight::Engine.config.exhibit_themes.include? fragment
    }

    collection :main_navigations, class: Spotlight::MainNavigation, decorator: MainNavigationRepresenter, if: config?(:config)
    collection :contact_emails, class: Spotlight::ContactEmail, if: config?(:config) do
      (Spotlight::ContactEmail.attribute_names - %w[id exhibit_id confirmation_token]).each do |prop|
        property prop
      end
    end

    collection :searches, populator: ->(fragment, options) { options[:represented].searches.find_or_initialize_by(slug: fragment['slug']) },
                          if: config?(:pages),
                          class: Spotlight::Search do
      (Spotlight::Search.attribute_names - %w[id scope exhibit_id masthead_id thumbnail_id]).each do |prop|
        property prop
      end

      property :masthead, class: Spotlight::Masthead,
                          decorator: FeaturedImageRepresenter,
                          if: Spotlight::ExhibitExportSerializer.config?(:attachments)

      property :thumbnail, class: Spotlight::FeaturedImage,
                           decorator: FeaturedImageRepresenter,
                           if: Spotlight::ExhibitExportSerializer.config?(:attachments)
    end

    collection :about_pages, populator: ->(fragment, options) { options[:represented].about_pages.find_or_initialize_by(slug: fragment['slug']) },
                             if: config?(:pages),
                             class: Spotlight::AboutPage,
                             decorator: PageRepresenter

    collection :feature_pages, populator: ->(fragment, options) { options[:represented].feature_pages.find_or_initialize_by(slug: fragment['slug']) },
                               getter: ->(_opts) { feature_pages.at_top_level },
                               class: Spotlight::FeaturePage,
                               decorator: NestedPageRepresenter,
                               if: config?(:pages)

    property :home_page, populator: ->(_fragment, options) { options[:represented].home_page },
                         class: Spotlight::HomePage,
                         decorator: PageRepresenter,
                         if: config?(:pages)

    collection :contacts, populator: ->(fragment, options) { options[:represented].contacts.find_or_initialize_by(slug: fragment['slug']) },
                          class: Spotlight::Contact,
                          if: config?(:pages) do
      (Spotlight::Contact.attribute_names - %w[id exhibit_id]).each do |prop|
        property prop
      end

      property :avatar, class: Spotlight::ContactImage, decorator: FeaturedImageRepresenter
    end

    property :masthead, class: Spotlight::Masthead, decorator: FeaturedImageRepresenter, if: config?(:attachments)

    property :thumbnail, class: Spotlight::ExhibitThumbnail, decorator: FeaturedImageRepresenter, if: config?(:attachments)

    property :blacklight_configuration, class: Spotlight::BlacklightConfiguration, decorator: ConfigurationRepresenter, if: config?(:blacklight_configuration)

    collection :custom_fields, populator: ->(fragment, options) { options[:represented].custom_fields.find_or_initialize_by(slug: fragment['slug']) },
                               class: Spotlight::CustomField,
                               if: config?(:blacklight_configuration) do
      (Spotlight::CustomField.attribute_names - %w[id exhibit_id]).each do |prop|
        property prop
      end
    end

    collection :solr_document_sidecars, class: Spotlight::SolrDocumentSidecar,
                                        if: config?(:resources) do
      (Spotlight::SolrDocumentSidecar.attribute_names - %w[id document_type exhibit_id]).each do |prop|
        property prop
      end

      property :document_type, exec_context: :decorator

      def document_type
        represented.document_type.to_s
      end

      delegate :document_type=, to: :represented
    end

    collection :owned_taggings, class: ActsAsTaggableOn::Tagging,
                                if: config?(:resources) do
      property :taggable_id
      property :taggable_type
      property :context
      property :tag, exec_context: :decorator

      def tag
        represented.tag.name
      end

      def tag=(tag)
        represented.tag = ActsAsTaggableOn::Tag.find_or_create_by name: tag
      end
    end

    collection :attachments, class: Spotlight::Attachment, if: config?(:attachments) do
      (Spotlight::Attachment.attribute_names - %w[id exhibit_id file]).each do |prop|
        property prop
      end

      property :file, exec_context: :decorator

      def file
        file = represented.file.file

        { filename: file.filename, content_type: file.content_type, content: Base64.encode64(file.read) }
      end

      def file=(file)
        represented.file = CarrierWave::SanitizedFile.new tempfile: StringIO.new(Base64.decode64(file['content'])),
                                                          filename: file['filename'],
                                                          content_type: file['content_type']
      end
    end

    collection :resources, class: ->(options) { options[:fragment].key?('type') ? options[:fragment]['type'].constantize : Spotlight::Resource },
                           if: config?(:resources) do
      (Spotlight::Resource.attribute_names - %w[id upload_id exhibit_id]).each do |prop|
        property prop
      end

      property :upload, exec_context: :decorator

      def upload
        return unless represented.is_a? Spotlight::Resources::Upload

        FeaturedImageRepresenter.new(represented.upload).to_json
      end

      def upload=(json)
        return unless represented.is_a? Spotlight::Resources::Upload

        FeaturedImageRepresenter.new(represented.build_upload).from_json(json)
      end
    end

    collection :languages, class: Spotlight::Language,
                           populator: ->(fragment, options) { options[:represented].languages.find_or_initialize_by(locale: fragment['locale']) },
                           if: config?(:config) do
      (Spotlight::Language.attribute_names - %w[id exhibit_id]).each do |prop|
        property prop
      end
    end

    collection :translations, getter: ->(represented:, **) { represented.translations.unscope(where: :locale) },
                              populator: (lambda do |fragment, options|
                                            options[:represented].translations
                                                                 .unscope(where: :locale)
                                                                 .find_or_initialize_by(locale: fragment['locale'], key: fragment['key'])
                                          end),
                              class: I18n::Backend::ActiveRecord::Translation,
                              if: config?(:config) do
      property :locale
      property :key
      property :value
      property :interpolations
      property :is_proc
    end
  end
end
