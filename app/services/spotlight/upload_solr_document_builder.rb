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
      riiif = Riiif::Engine.routes.url_helpers
      resource.spotlight_image_derivatives.each do |config|
        solr_hash[config[:field]] = if config[:version]
                                      # TODO: this path is wrong until Uploads are merged with FeaturedImage.
                                      riiif.image_path(resource.id, size: image_size(config[:version]))
                                    else
                                      riiif.image_path(resource.id, size: 'full')
                                    end
      end
    end

    def image_size(version)
      case version
      when :thumb
        '400x400'
      when :square
        '100x100'
      else
        raise "What size should we use for #{config[:version]}?"
      end
    end

    def add_sidecar_fields(solr_hash)
      solr_hash.merge! resource.sidecar.to_solr
    end
  end
end
