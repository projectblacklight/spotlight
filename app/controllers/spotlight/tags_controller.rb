module Spotlight
  class TagsController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource class: ActsAsTaggableOn::Tag

    def index
      respond_to do |format|
        format.html
        format.json { render json: @tags.map { |x| x.name } }
      end
    end

    def destroy
      @tag.destroy # warning: this causes every solr document with this tag to reindex.  That could be slow.
      redirect_to exhibit_tags_path(@exhibit)
    end
  end
end
