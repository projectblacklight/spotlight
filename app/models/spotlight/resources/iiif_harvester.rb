module Spotlight::Resources
  # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
  class IiifHarvester < Spotlight::Resource
    self.weight = -5000

    after_save :harvest_resources


  end
end