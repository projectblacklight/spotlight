module Spotlight
  ##
  # CRUD actions for the exhibit home page
  class HomePagesController < Spotlight::PagesController
    include Blacklight::SearchHelper
    include Spotlight::Catalog

    load_and_authorize_resource through: :exhibit, singleton: true, instance_name: 'page'

    before_action :attach_breadcrumbs, except: :show

    def edit
      add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      add_breadcrumb @page.title, [:edit, @exhibit, @page]
      super
    end

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      @response, @document_list = search_results({}) if @page.display_sidebar?

      if @page.nil? || !@page.published?
        render '/catalog/index'
      else
        render 'show'
      end
    end

    # We're oddly getting an unknown action
    # error w/o explicitly defining this here
    def clone
      super
    end

    private

    alias search_action_url exhibit_search_action_url
    alias search_facet_url exhibit_search_facet_url

    def load_locale_specific_page
      @page = Spotlight::HomePage.for_locale.find_by(exhibit: current_exhibit)
    end

    def allowed_page_params
      super.concat [:display_title, :display_sidebar]
    end
  end
end
