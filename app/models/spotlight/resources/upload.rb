module Spotlight
  class Resources::Upload < Spotlight::Resource
    mount_uploader :url, Spotlight::ItemUploader
    include Spotlight::ImageDerivatives
    
    # we want to do this before reindexing
    after_create :update_document_sidecar

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

      add_file_versions solr_hash

      add_sidecar_fields solr_hash

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

    def add_file_versions solr_hash
      spotlight_image_derivatives.each do |config|
        if config[:version]
          solr_hash[config[:field]] = url.send(config[:version]).url
        else
          solr_hash[config[:field]] = url.url
        end
      end
    end

    def add_sidecar_fields solr_hash
      solr_hash.merge! sidecar.to_solr
    end

    def compound_id
      "#{exhibit_id}-#{id}"
    end
    
    def update_document_sidecar
      sidecar_updates = data.slice(*exhibit.custom_fields.map(&:field).map(&:to_s)).select { |k,v| v.present? }

      sidecar_updates["configured_fields"] = data.slice(*configured_fields.map(&:field_name).map(&:to_s)).select { |k,v| v.present? }

      sidecar.update(data: sidecar.data.merge(sidecar_updates))

      sidecar.save
    end

    def sidecar
      @sidecar ||= solr_document_model.new(id: compound_id).sidecar(exhibit)
    end

  end
end
