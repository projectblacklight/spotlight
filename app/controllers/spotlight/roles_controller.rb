module Spotlight
  ##
  # CRUD actions for assigning exhibit roles to
  # existing users
  class RolesController < Spotlight::ApplicationController
    include Spotlight::Concerns::UserExistable
    include Spotlight::Concerns::UserInvitable
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource through: :exhibit, except: [:update_all]

    def index
      role = @exhibit.roles.build
      authorize! :edit, role

      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.configuration.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.configuration.sidebar.users'), exhibit_roles_path(@exhibit)
    end

    def update_all
      authorize_nested_attributes! exhibit_params[:roles_attributes], Role

      if @exhibit.update(exhibit_params)
        notice = any_deleted ? t(:'helpers.submit.role.destroyed') : t(:'helpers.submit.role.updated')
        redirect_to exhibit_roles_path(@exhibit), notice: notice
      else
        flash[:alert] = t(:'helpers.submit.role.batch_error')
        render action: 'index'
      end
    end

    protected

    def exhibit_params
      params.require(:exhibit).permit(roles_attributes: [:id, :user_key, :role, :_destroy])
    end

    def any_deleted
      exhibit_params[:roles_attributes].values.any? do |item|
        item['_destroy'].present? && item['_destroy'] != 'false'
      end
    end

    # When nested attributes are passed in, ensure we have authorization to update each row.
    # @param attr [Hash,Array] the nested attributes
    # @param klass [Class] the class that is getting created
    # @return [Integer] a count of the number of deleted records
    def authorize_nested_attributes!(attrs, klass)
      attrs.each do |_, item|
        authorize_item item, klass
      end
    end

    def authorize_item(item, klass)
      if item[:id]
        if item['_destroy'].present?
          authorize! :destroy, klass.find(item[:id])
        else
          authorize! :update, klass.find(item[:id])
        end
      else
        authorize! :create, klass
      end
    end
  end
end
