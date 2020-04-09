# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require 'base64'
require 'tempfile'

module Spotlight
  # Utility service for importing and exporting exhibit data
  class ExhibitImportExportService
    class_attribute :serialization_pipeline, default: %i[
      raw_json
      add_feature_page_hierarchy
      add_page_content
      attach_featured_images
      attach_attachments
    ]

    attr_reader :exhibit, :include

    def initialize(exhibit, include: Spotlight::Engine.config.exports)
      @exhibit = exhibit
      @include = include
    end

    def from_hash!(hash)
      hash = hash.deep_symbolize_keys.reverse_merge(
        main_navigations: {},
        contact_emails: {},
        searches: {},
        about_pages: {},
        feature_pages: {},
        contacts: {},
        custom_fields: {},
        solr_document_sidecars: {},
        resources: {},
        attachments: {},
        languages: {},
        translations: {},
        owned_taggings: {}
      )

      exhibit_attributes = hash.reject { |_k, v| v.is_a?(Array) || v.is_a?(Hash) }
      exhibit.update_attributes(exhibit_attributes.except(:theme))
      exhibit.theme = exhibit_attributes[:theme] if exhibit.themes.include? exhibit_attributes[:theme]

      deserialize_featured_image(exhibit, :masthead, hash[:masthead]) if hash[:masthead]
      deserialize_featured_image(exhibit, :thumbnail, hash[:thumbnail]) if hash[:thumbnail]

      exhibit.blacklight_configuration.attributes = hash[:blacklight_configuration] if hash[:blacklight_configuration]

      hash[:main_navigations].each do |attr|
        ar = exhibit.main_navigations.find_or_initialize_by(nav_type: attr[:nav_type])
        ar.update_attributes(attr)
      end

      hash[:contact_emails].each do |attr|
        ar = exhibit.contact_emails.find_or_initialize_by(email: attr[:email])
        ar.update_attributes(attr)
      end

      hash[:searches].each do |attr|
        masthead = attr.delete(:masthead)
        thumbnail = attr.delete(:thumbnail)

        ar = exhibit.searches.find_or_initialize_by(slug: attr[:slug])
        ar.update_attributes(attr)

        deserialize_featured_image(ar, :masthead, masthead) if masthead
        deserialize_featured_image(ar, :thumbnail, thumbnail) if thumbnail
      end

      hash[:about_pages].each do |attr|
        masthead = attr.delete(:masthead)
        thumbnail = attr.delete(:thumbnail)

        ar = exhibit.about_pages.find_or_initialize_by(slug: attr[:slug])
        ar.update_attributes(attr)

        deserialize_featured_image(ar, :masthead, masthead) if masthead
        deserialize_featured_image(ar, :thumbnail, thumbnail) if thumbnail
      end

      hash[:feature_pages].each do |attr|
        masthead = attr.delete(:masthead)
        thumbnail = attr.delete(:thumbnail)

        ar = exhibit.feature_pages.find_or_initialize_by(slug: attr[:slug])
        ar.update_attributes(attr.except(:parent_page_slug))

        deserialize_featured_image(ar, :masthead, masthead) if masthead
        deserialize_featured_image(ar, :thumbnail, thumbnail) if thumbnail
      end

      feature_pages = exhibit.feature_pages.index_by(&:slug)
      hash[:feature_pages].each do |attr|
        next unless attr[:parent_page_slug]

        feature_pages[attr[:slug]].parent_page_id = feature_pages[attr[:parent_page_slug]].id
      end

      if hash[:home_page]
        exhibit.home_page.attributes = hash[:home_page].except(:thumbnail)
        deserialize_featured_image(exhibit.home_page, :thumbnail, hash[:home_page][:thumbnail]) if hash[:home_page][:thumbnail]
      end

      hash[:contacts].each do |attr|
        avatar = attr.delete(:avatar)

        ar = exhibit.contacts.find_or_initialize_by(slug: attr[:slug])
        ar.update_attributes(attr)

        deserialize_featured_image(ar, :avatar, avatar) if avatar
      end

      hash[:custom_fields].each do |attr|
        ar = exhibit.custom_fields.find_or_initialize_by(slug: attr[:slug])
        ar.update_attributes(attr)
      end

      hash[:solr_document_sidecars].each do |attr|
        ar = exhibit.solr_document_sidecars.find_or_initialize_by(document_id: attr[:document_id])
        ar.update_attributes(attr)
      end

      hash[:resources].each do |attr|
        upload = attr.delete(:upload)

        ar = exhibit.resources.find_or_initialize_by(type: attr[:type], url: attr[:url])
        ar.update_attributes(attr)

        deserialize_featured_image(ar, :upload, upload) if upload
      end

      hash[:attachments].each do |attr|
        file = attr.delete(:file)

        # dedupe by something??
        ar = exhibit.attachments.build(attr)
        ar.file = CarrierWave::SanitizedFile.new tempfile: StringIO.new(Base64.decode64(file[:content])),
                                                 filename: file[:filename],
                                                 content_type: file[:content_type]
      end

      hash[:languages].each do |attr|
        ar = exhibit.languages.find_or_initialize_by(locale: attr[:locale])
        ar.update_attributes(attr)
      end

      hash[:translations].each do |attr|
        ar = exhibit.translations.find_or_initialize_by(locale: attr[:locale], key: attr[:key])
        ar.update_attributes(attr)
      end

      hash[:owned_taggings].each do |attr|
        tag = ActsAsTaggableOn::Tag.find_or_create_by(name: attr[:tag][:name])
        exhibit.owned_taggings.build(attr.except(:tag).merge(tag_id: tag.id))
      end
    end

    def deserialize_featured_image(obj, method, data)
      file = data.delete(:image)
      image = obj.public_send("build_#{method}")
      if file
        image.image = CarrierWave::SanitizedFile.new tempfile: StringIO.new(Base64.decode64(file[:content])),
                                                     filename: file[:filename],
                                                     content_type: file[:content_type]
      end
      image.save!
      obj.update(method => image)
    end

    def as_json(**args)
      self.class.serialization_pipeline.inject(args) do |memo, step|
        method(step).call(memo)
      end
    end

    private

    def attach_featured_images(json)
      json[:masthead] = serialize_featured_image(json[:masthead_id]) if json[:masthead_id]
      json.delete(:masthead_id)
      json[:thumbnail] = serialize_featured_image(json[:thumbnail_id]) if json[:thumbnail_id]
      json.delete(:thumbnail_id)

      (json[:searches] || []).each do |search|
        search[:masthead] = serialize_featured_image(search[:masthead_id]) if search[:masthead_id]
        search.delete(:masthead_id)
        search[:thumbnail] = serialize_featured_image(search[:thumbnail_id]) if search[:thumbnail_id]
        search.delete(:thumbnail_id)
      end

      (json[:about_pages] || []).each do |page|
        page[:masthead] = serialize_featured_image(page[:masthead_id]) if page[:masthead_id]
        page.delete(:masthead_id)
        page[:thumbnail] = serialize_featured_image(page[:thumbnail_id]) if page[:thumbnail_id]
        page.delete(:thumbnail_id)
      end

      (json[:feature_pages] || []).each do |page|
        page[:masthead] = serialize_featured_image(page[:masthead_id]) if page[:masthead_id]
        page.delete(:masthead_id)
        page[:thumbnail] = serialize_featured_image(page[:thumbnail_id]) if page[:thumbnail_id]
        page.delete(:thumbnail_id)
      end

      if json[:home_page]
        json[:home_page][:masthead] = serialize_featured_image(json[:home_page][:masthead_id]) if json[:home_page][:masthead_id]
        json[:home_page].delete(:masthead_id)
        json[:home_page][:thumbnail] = serialize_featured_image(json[:home_page][:thumbnail_id]) if json[:home_page][:thumbnail_id]
        json[:home_page].delete(:thumbnail_id)
      end

      (json[:contacts] || []).each do |page|
        page[:avatar] = serialize_featured_image(page[:avatar_id]) if page[:avatar_id]
        page.delete(:avatar_id)
      end

      (json[:resources] || []).each do |page|
        page[:upload] = serialize_featured_image(page[:upload_id]) if page[:upload_id]
        page.delete(:upload_id)
      end

      json
    end

    def serialize_featured_image(id)
      image = Spotlight::FeaturedImage.find(id)
      file = image.image.file
      if file
        img = {
          image: {
            filename: file.identifier, content_type: file.content_type, content: Base64.encode64(file.read)
          }
        }
      end

      image.as_json(except: %i[id image]).merge(img || {}).deep_symbolize_keys
    end

    def attach_attachments(json)
      return json unless json[:attachments]

      json[:attachments].each do |attachment|
        a = exhibit.attachments.find(attachment[:id])
        file = a.file.file

        attachment[:file] = {
          filename: file.filename,
          content_type: file.content_type,
          content: Base64.encode64(file.read)
        }

        attachment.delete(:id)
      end

      json
    end

    def add_feature_page_hierarchy(json)
      return json unless json[:feature_pages]

      page_id_map = json[:feature_pages].map { |x| [x[:id], x[:slug]] }.to_h

      json[:feature_pages].each do |page|
        page.delete(:id)
        next unless page[:parent_page_id]

        page[:parent_page_slug] = page_id_map[page[:parent_page_id]]
        page.delete(:parent_page_id)
      end

      json
    end

    def add_page_content(json)
      (json[:feature_pages] || []).each do |page|
        page[:content] = exhibit.feature_pages.find_by(slug: page[:slug]).read_attribute(:content)
      end

      (json[:about_pages] || []).each do |page|
        page[:content] = exhibit.about_pages.find_by(slug: page[:slug]).read_attribute(:content)
      end

      json[:home_page][:content] = exhibit.home_page.read_attribute(:content) if json[:home_page]

      json
    end

    def raw_json(_input = nil)
      exhibit.as_json(
        {
          except: %i[id slug site_id],
          include: {}.merge(
            if_include?(:config,
                        main_navigations: {
                          except: %i[id exhibit_id]
                        },
                        contact_emails: {
                          except: %i[id exhibit_id confirmation_token]
                        },
                        languages: {
                          except: %i[id exhibit_id]
                        },
                        translations: {
                          only: %i[locale key value interpolations is_proc]
                        })
          ).merge(
            if_include?(:pages,
                        searches: { # thumbnail
                          except: %i[id scope exhibit_id]
                        },
                        about_pages: { # thumbnail
                          except: %i[id scope exhibit_id parent_page_id content]
                        },
                        home_page: { # thumbnail
                          except: %i[id scope exhibit_id parent_page_id content]
                        },
                        feature_pages: { # thumbnail
                          except: %i[scope exhibit_id content]
                        },
                        contacts: {
                          except: %i[id exhibit_id]
                        })
          ).merge(
            if_include?(:blacklight_configuration,
                        blacklight_configuration: {
                          except: %i[id exhibit_id]
                        },
                        # blacklight_configuration
                        custom_fields: {
                          except: %i[id exhibit_id]
                        })
          ).merge(
            if_include?(:resources,
                        # resources
                        solr_document_sidecars: {
                          except: %i[id exhibit_id]
                        },
                        owned_taggings: {
                          only: %i[taggable_id taggable_type context],
                          include: {
                            tag: {
                              only: [:name]
                            }
                          }
                        },
                        resources: { # upload
                          except: %i[id exhibit_id],
                          methods: :type
                        })
          ).merge(
            if_include?(:attachments,
                        # attachments
                        attachments: { # file
                          except: %i[exhibit_id]
                        })
          )
        }.merge(include[:config] ? {} : { only: %i[does_not_exist] })
      ).deep_symbolize_keys
    end

    def if_include?(config, res)
      include[config] ? res : {}
    end
  end
end
