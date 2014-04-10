module Spotlight::SolrDocument::Openseadragon
  def to_openseadragon view_config = nil
    if view_config and view_config.tile_source_field
      Array(get(view_config.tile_source_field, sep: nil))
    end
  end
end
