module Spotlight
  class Resources::Upload < Spotlight::Resource
    mount_uploader :url, Spotlight::ItemUploader

    def to_solr
      store_url! # so that #url doesn't return the tmp directory
      construct_solr_hash!
      to_solr_hash
    end

    def self.fields(exhibit)
      @fields ||= self.new(exhibit: exhibit).configured_fields
    end

    def configured_fields
      @configured_fields ||= [configured_title_field] + Spotlight::Engine.config.upload_fields
    end

    private

    # this is in the upload class because it has exhibit context
    def configured_title_field
      OpenStruct.new(solr_field: exhibit.blacklight_config.index.title_field)
    end

    def to_solr_hash
      @to_solr_hash ||= {}
    end

    def construct_solr_hash!
      add_default_solr_fields

      add_image_dimensions

      add_custom_fields

      add_configured_fields

      add_file_versions
    end

    def add_default_solr_fields
      to_solr_hash[::SolrDocument.unique_key.to_sym] = compound_id
      to_solr_hash[exhibit.blacklight_config.index.full_image_field] = url.url
      to_solr_hash[:spotlight_resource_type_ssm] = self.class.to_s.tableize
    end

    def add_image_dimensions
      dimensions = ::MiniMagick::Image.open(url.file.file)[:dimensions]
      to_solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      to_solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def add_custom_fields
      exhibit.custom_fields.collect(&:field).each do |solr_field|
        if data[solr_field].present?
          to_solr_hash[solr_field] = data[solr_field]
        end
      end
    end

    def add_configured_fields
      configured_fields.collect(&:solr_field).each do |solr_field|
        if data[solr_field].present?
          to_solr_hash[solr_field] = data[solr_field]
        end
      end
    end

    def add_file_versions
      Spotlight::ItemUploader.configured_versions.each do |config|
        to_solr_hash[exhibit.blacklight_config.index.send(config[:blacklight_config_field])] = url.send(config[:version]).url
      end
    end

    def compound_id
      "#{exhibit_id}-#{id}"
    end
  end
end
