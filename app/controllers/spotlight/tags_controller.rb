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

    def update_all
      tags_to_rename = batch_update_params['owned_tags_attributes'].values.select do |tag|
        tag[:name]&.present? && tag[:current_name]&.strip != tag[:name]&.strip
      end

      rename_tags_later!(tags_to_rename)

      redirect_back fallback_location: fallback_url, notice: t(:'helpers.submit.tags.batch_updated', count: tags_to_rename.count)
    end

    private

    def rename_tags_later!(tags_to_rename)
      tags_to_rename.each do |tag|
        Spotlight::RenameTagsJob.perform_later(@exhibit, @exhibit.owned_tags.find(tag[:id]), to: tag[:name])
      end
    end

    def fallback_url
      spotlight.exhibit_tags_path(@exhibit)
    end

    def batch_update_params
      params.require(:exhibit).permit('owned_tags_attributes' => %i[id current_name name])
    end
  end
end
