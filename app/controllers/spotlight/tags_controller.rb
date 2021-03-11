# frozen_string_literal: true

module Spotlight
  ##
  # CRUD actions for document tags
  class TagsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_resource :tag, through: :exhibit, through_association: :owned_tags, except: [:index], class: 'ActsAsTaggableOn::Tag'

    before_action do
      authorize! :tag, @exhibit
    end

    def index
      @tags = @exhibit.owned_tags
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.tags'), exhibit_tags_path(@exhibit)

      respond_to do |format|
        format.html
        format.json { render json: @tags.map(&:name) }
      end
    end

    def destroy
      Spotlight::RenameTagsJob.perform_later(@exhibit, @tag, to: nil)

      redirect_to exhibit_tags_path(@exhibit)
    end

    def rename
      Spotlight::RenameTagsJob.perform_later(@exhibit, @tag, to: params[:new_tag])

      redirect_to exhibit_tags_path(@exhibit)
    end
  end
end
