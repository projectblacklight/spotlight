module Spotlight
  class Resources::Upload < Spotlight::Resource
    mount_uploader :url, Spotlight::ItemUploader

    def to_solr
      store_url! # so that #url doesn't return the tmp directory
      to_solr_hash
    end

    def self.fields(exhibit)
      @fields ||= self.new(exhibit: exhibit).configured_fields
    end

    def configured_fields
      @configured_fields ||= configured_title_field.merge(Spotlight::Engine.config.upload_fields)
    end

    private

    # this is in the upload class because it has exhibit context
    def configured_title_field
      {title: OpenStruct.new(solr_field: exhibit.blacklight_config.index.title_field)}
    end

    def to_solr_hash
      solr_hash = {
        ::SolrDocument.unique_key.to_sym => compound_id,
        exhibit.blacklight_config.index.full_image_field => url.url,
        spotlight_resource_type_ssm: self.class.to_s.tableize
      }

      add_image_dimensions(solr_hash)

      Spotlight::ItemUploader.configured_versions.each do |config|
        solr_hash[exhibit.blacklight_config.index.send(config[:blacklight_config_field])] = url.send(config[:version]).url
      end
      configured_fields.each do |key, config|
        if data[key].present?
          solr_hash[config.solr_field] = data[key]
        end
      end
      solr_hash
    end

    def add_image_dimensions(solr_hash)
      dimensions = ::MiniMagick::Image.open(url.file.file)[:dimensions]
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def compound_id
      "#{exhibit_id}-#{id}"
    end
  end
end
