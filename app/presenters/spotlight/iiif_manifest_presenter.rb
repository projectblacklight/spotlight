# frozen_string_literal: true

module Spotlight
  ##
  # A presenter class that provides the methods that IIIFManifest expects, as well as convenience methods
  #  that will generate a IIIFManifest object, and the actual JSON manifest from the IIIFManifest object.
  #  Instances of this class represent IIIF leaf nodes.  We do not currently generate manifests with interstitial
  #  nodes.
  #
  # IIIFManifest expects the following methods:  #file_set_presenters, #work_presenters, #manifest_url, #description.
  #  see: https://github.com/projecthydra-labs/iiif_manifest/blob/master/README.md
  class IiifManifestPresenter
    require 'iiif_manifest'

    # The class that represents the leaf nodes must implement #id (here implemented
    # via delegation to the resource, since this class represents leaf nodes).
    delegate :id, :uploaded_resource, to: :resource
    delegate :blacklight_config, to: :controller

    attr_accessor :resource, :controller

    def initialize(resource, controller)
      @resource = resource
      @controller = controller
    end

    # IIIFManifest expects leaf nodes to implement #display_image, which returns an instance of IIIFManifest::DisplayImage.
    def display_image
      IIIFManifest::DisplayImage.new(id,
                                     width: resource.first(:spotlight_full_image_width_ssm),
                                     height: resource.first(:spotlight_full_image_height_ssm),
                                     format: 'image/jpeg',
                                     iiif_endpoint: endpoint)
    end

    # Returns an array of leaf nodes.  Currently, this is a single element array containing this presenter
    # instance, since we're only building a single-image manifest for the given resource.
    def file_set_presenters
      [self]
    end

    # This is an empty array, since we're not building manifests for works at the moment.
    def work_presenters
      []
    end

    # where this manifest can be found
    def manifest_url
      controller.spotlight.manifest_exhibit_solr_document_url(uploaded_resource.exhibit, resource)
    end

    # a description of the manifest
    def description
      resource.first(Spotlight::Engine.config.upload_description_field)
    end

    # IIIFManifest will call #to_s on each leaf node to get its respective label (not called out in README).
    def to_s
      resource.first(blacklight_config.view_config(:show).title_field)
    end

    def iiif_manifest
      IIIFManifest::ManifestFactory.new(self)
    end

    def iiif_manifest_json
      iiif_manifest.to_h.to_json
    end

    private

    def endpoint
      IIIFManifest::IIIFEndpoint.new(iiif_url, profile: 'http://iiif.io/api/image/2/level2.json')
    end

    def iiif_url
      # yes this is hacky, and we are appropriately ashamed.
      controller.riiif.info_url(uploaded_resource.upload.id).sub(%r{/info\.json\Z}, '')
    end
  end
end
