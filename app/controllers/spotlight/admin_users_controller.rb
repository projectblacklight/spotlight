module Spotlight
  ##
  # A controller to handle the adminstration of site admin users
  class AdminUsersController < Spotlight::ApplicationController
    include Spotlight::Concerns::UserExistable
    include Spotlight::Concerns::UserInvitable

    before_action :authenticate_user!
    before_action :load_site
    load_and_authorize_resource :site, class: 'Spotlight::Site'

    def index
    end

    def create
      if update_roles
        flash[:notice] = t('spotlight.admin_users.create.success')
      else
        flash[:error] = t('spotlight.admin_users.create.error')
      end
      redirect_to spotlight.admin_users_path
    end

    def destroy
      user = Spotlight::Engine.user_class.find(params[:id])
      if user.roles.where(resource: @site).first.destroy
        flash[:notice] = t('spotlight.admin_users.destroy.success')
      else
        flash[:error] = t('spotlight.admin_users.destroy.error')
      end
      redirect_to spotlight.admin_users_path
    end

    private

    def load_site
      @site ||= Spotlight::Site.instance
    end

    def create_params
      params.require(:user).permit(:email)
    end

    def update_roles
      user = Spotlight::Engine.user_class.where(email: create_params[:email]).first
      Spotlight::Role.create(user: user, role: 'admin', resource: @site).save
    end
  end
end
