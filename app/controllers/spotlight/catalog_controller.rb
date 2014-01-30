class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  before_filter :check_authorization

  copy_blacklight_config_from ::CatalogController
  self.blacklight_config.index.partials = [:index_compact]

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  protected

  def check_authorization
    authorize! :curate, Spotlight::Exhibit.default
  end
end
