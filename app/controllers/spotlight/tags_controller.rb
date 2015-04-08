module Spotlight
  ##
  # CRUD actions for document tags
  class TagsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    def index
      authorize! :tag, @exhibit
      @tags = @exhibit.owned_tags
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.tags'), exhibit_tags_path(@exhibit)

      respond_to do |format|
        format.html
        format.json { render json: @exhibit.owned_tags.map(&:name) }
      end
    end

    def destroy
      authorize! :tag, @exhibit
      # warning: this causes every solr document with this tag to reindex.  That could be slow.
      @exhibit.owned_taggings.where(tag_id: params[:id]).destroy_all

      redirect_to exhibit_tags_path(@exhibit)
    end
  end
end
