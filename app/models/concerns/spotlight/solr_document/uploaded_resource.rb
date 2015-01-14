module Spotlight::SolrDocument::UploadedResource
  def to_openseadragon(*args)
    self[Spotlight::Engine.config.full_image_field].each_with_index.map do |image_url, index|
      {LegacyImagePyramidTileSource.new(
         image_url,
         {width: self[:spotlight_full_image_width_ssm][index],
          height: self[:spotlight_full_image_height_ssm][index]}
       ) => {}
      } 
    end
  end
  class LegacyImagePyramidTileSource
    attr_reader :to_tilesource
    def initialize(url, dimensions={})
      @to_tilesource = {
        type: 'legacy-image-pyramid',
        levels:[{
          url: url,
          width: dimensions[:width],
          height: dimensions[:height]
        }]
      }
    end
  end
end
