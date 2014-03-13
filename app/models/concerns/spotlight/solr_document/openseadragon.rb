module Spotlight::SolrDocument::Openseadragon
  def to_openseadragon view_config = nil
    if view_config and view_config.iiif_tile_source_field
      Array(get(view_config.iiif_tile_source_field, sep: nil)).map do |url|
        Openseadragon::Info.new(id: url)
      end
    end
  end
end
