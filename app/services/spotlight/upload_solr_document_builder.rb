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

      add_sidecar_fields solr_hash

      solr_hash
    end

    private

    def add_default_solr_fields(solr_hash)
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions(solr_hash)
      dimensions = ::MiniMagick::Image.open(resource.url.file.file)[:dimensions]
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def add_file_versions(solr_hash)
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
