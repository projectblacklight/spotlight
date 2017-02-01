module Spotlight
  # Creates solr documents for the uploaded documents in a resource
  class UploadSolrDocumentBuilder < SolrDocumentBuilder
    delegate :compound_id, to: :resource

    def to_solr
      resource.store_url! # so that #url doesn't return the tmp directory

      solr_hash = super

      add_default_solr_fields solr_hash

      add_image_dimensions solr_hash

      add_file_versions solr_hash

      make_thumbnails solr_hash

      add_sidecar_fields solr_hash

      solr_hash
    end

    private

    def make_thumbnails(solr_hash)
      return unless resource.thumb?
      solr_hash[Spotlight::Engine.config.try(:thumbnail_field)] = resource.thumb.thumb.url
      solr_hash[Spotlight::Engine.config.try(:square_image_field)] = resource.thumb.square.url
      solr_hash[Spotlight::Engine.config.try(:full_image_field)] = resource.url.url
    end

    def add_default_solr_fields(solr_hash)
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions(solr_hash)
      return if resource.audio? || resource.video?
      dimensions = ::MiniMagick::Image.open(resource.url.file.file)[:dimensions]
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def add_file_versions(solr_hash)
      return if resource.thumb?
      resource.spotlight_image_derivatives.each do |config|
        solr_hash[config[:field]] = if config[:version]
                                      resource.url.send(config[:version]).url
                                    else
                                      resource.url.url
                                    end
      end
    end

    def add_sidecar_fields(solr_hash)
      solr_hash.merge! resource.sidecar.to_solr
    end
  end
end
