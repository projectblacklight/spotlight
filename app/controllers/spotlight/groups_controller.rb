# frozen_string_literal: true

module Spotlight
  ##
  # Base CRUD controller for groups
  class GroupsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource through: :exhibit

    def index
      respond_to do |format|
        format.json do
          render json: @groups.as_json, root: false
        end
      end
    end

    # POST /exhibits/1/groups
    def create
      @group.attributes = group_params

      if @group.save
        redirect_to(
          spotlight.exhibit_searches_path(anchor: 'browse-groups'),
          notice: t(:'helpers.submit.group.created', model: human_name)
        )
      else
        redirect_to spotlight.exhibit_searches_path(anchor: 'browse-groups')
      end
    end

    # PATCH/PUT /groups/1
    def update
      @group.update(group_params)

      redirect_to spotlight.exhibit_searches_path(anchor: 'browse-groups'), notice: t(:'helpers.submit.group.updated', model: human_name)
    end

    # DELETE /groups/1
    def destroy
      @group.destroy

      redirect_to spotlight.exhibit_searches_path(anchor: 'browse-groups'), alert: t(:'helpers.submit.group.destroyed', model: human_name)
    end

    def update_all
      notice = if @exhibit.update update_all_group_params
                 t(:'helpers.submit.group.batch_updated', model: human_name)
               else
                 t(:'helpers.submit.group.batch_error', model: human_name)
               end
      redirect_to spotlight.exhibit_searches_path(anchor: 'browse-groups'), notice:
    end

    protected

    def allowed_group_params
      [:title]
    end

    private

    def human_name
      @human_name ||= @group ? @group.class.model_name.human.downcase : Spotlight::Group.model_name.human.pluralize
    end

    alias group_collection_name controller_name

    def update_all_group_params
      params.require(:exhibit).permit(
        groups_attributes: %i[id title published weight]
      )
    end

    def group_params
      params.require(controller_name.singularize).permit(allowed_group_params)
    end
  end
end
