class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  copy_blacklight_config_from ::CatalogController
  self.blacklight_config.index.partials = [:index_compact]

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

end
