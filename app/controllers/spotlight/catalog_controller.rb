class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  load_resource :exhibit, class: Spotlight::Exhibit
  before_filter :check_authorization

  copy_blacklight_config_from ::CatalogController
  self.blacklight_config.index.partials = [:index_compact]

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  protected

  def check_authorization
    authorize! :curate, @exhibit
  end
end
