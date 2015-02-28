module Spotlight
  class Resources::Upload < Spotlight::Resource
    mount_uploader :url, Spotlight::ItemUploader
    include Spotlight::ImageDerivatives

    def self.fields(exhibit)
      @fields ||= {}
      @fields[exhibit] ||= self.new(exhibit: exhibit).configured_fields
    end

    def configured_fields
      @configured_fields ||= [configured_title_field] + Spotlight::Engine.config.upload_fields
    end

    def to_solr
      store_url! # so that #url doesn't return the tmp directory

      solr_hash = super
      
      solr_hash[:"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_url#{Spotlight::Engine.config.solr_fields.string_suffix}"] = url.url
      
      add_default_solr_fields solr_hash

      add_image_dimensions solr_hash
      
      add_custom_fields solr_hash
      
      add_configured_fields solr_hash
      
      add_file_versions solr_hash

      solr_hash
    end

    private

    # this is in the upload class because it has exhibit context
    def configured_title_field
      Spotlight::Engine.config.upload_title_field || OpenStruct.new(field_name: exhibit.blacklight_config.index.title_field)
    end
    
    def add_default_solr_fields solr_hash
      solr_hash[exhibit.blacklight_config.solr_document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions solr_hash
      dimensions = ::MiniMagick::Image.open(url.file.file)[:dimensions]
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def add_custom_fields solr_hash
      exhibit.custom_fields.collect(&:field).each do |solr_field|
        if data[solr_field].present?
          solr_hash[solr_field] = data[solr_field]
        end
      end
    end

    def add_configured_fields solr_hash
      configured_fields.each do |field|
        solr_fields = Array(field.solr_field || field.field_name)
        if data[field.field_name].present?
          solr_fields.each do |solr_field|
            solr_hash[solr_field] = data[field.field_name]
          end
        end
      end
    end

    def add_file_versions solr_hash
      @@spotlight_image_derivatives.each do |config|
        if config[:version]
          solr_hash[config[:field]] = url.send(config[:version]).url
        else
          solr_hash[config[:field]] = url.url
        end
      end
    end

    def compound_id
      "#{exhibit_id}-#{id}"
    end
  end
end
