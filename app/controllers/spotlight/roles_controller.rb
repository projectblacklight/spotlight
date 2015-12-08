module Spotlight
  ##
  # CRUD actions for assigning exhibit roles to
  # existing users
  class RolesController < Spotlight::ApplicationController
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

      any_deleted = exhibit_params[:roles_attributes].values.any? { |item| item['_destroy'].present? }

      if @exhibit.update(exhibit_params)
        notice = any_deleted ? t(:'helpers.submit.role.destroyed') : t(:'helpers.submit.role.updated')
        redirect_to exhibit_roles_path(@exhibit), notice: notice
      else
        flash[:alert] = t(:'helpers.submit.role.batch_error')
        render action: 'index'
      end
    end

    def exists
      # note: the messages returned are not shown to users and really only useful for debug, hence no translation necessary
      #  app uses html status code to act on response
      if ::User.where(email: exists_params).present?
        render json: { message: 'User exists' }
      else
        render json: { message: 'User does not exist' }, status: :not_found
      end
    end

    def invite
      user = ::User.invite!(email: invite_params[:user], skip_invitation: true) # don't deliver the invitation yet
      role = Spotlight::Role.create(exhibit: current_exhibit, user: user, role: invite_params[:role])
      if role.save
        user.deliver_invitation # now deliver it when we have saved the role
        redirect_to :back, notice: t(:'helpers.submit.role.updated')
      else
        redirect_to :back, alert: t(:'helpers.submit.role.batch_error')
      end
    end

    protected

    def exhibit_params
      params.require(:exhibit).permit(roles_attributes: [:id, :user_key, :role, :_destroy])
    end

    def invite_params
      params.permit(:user, :role)
    end

    def exists_params
      params.require(:user)
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
