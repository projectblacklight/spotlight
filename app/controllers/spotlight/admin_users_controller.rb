# frozen_string_literal: true

module Spotlight
  ##
  # A controller to handle the administration of users
  class AdminUsersController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :load_site
    before_action :load_users

    load_and_authorize_resource :site, class: 'Spotlight::Site'

    def index
      add_breadcrumb(t(:'spotlight.sites.home'), root_url)
      add_breadcrumb(t(:'spotlight.admin_users.index.page_title'))
    end

    def create
      if update_roles
        Spotlight::InviteUsersService.call(resource: @site)
        flash[:notice] = t('.success')
      else
        flash[:error] = t('.error')
      end

      redirect_to spotlight.admin_users_path
    end

    def update
      user = Spotlight::Engine.user_class.find(params[:id])
      if user
        Spotlight::Role.create(user_key: user.email, role: 'admin', resource: @site).save
        flash[:notice] = t('spotlight.admin_users.create.success')
      else
        flash[:error] = t('spotlight.admin_users.create.error')
      end

      redirect_to spotlight.admin_users_path
    end

    def destroy
      user = Spotlight::Engine.user_class.find(params[:id])
      if user.roles.where(resource: @site).first.destroy
        flash[:notice] = t('.success')
      else
        flash[:error] = t('.error')
      end
      redirect_to spotlight.admin_users_path
    end

    def remove_exhibit_roles
      user = Spotlight::Engine.user_class.find(params[:id])
      if user.all_exhibit_roles.destroy_all
        flash[:notice] = t('.success')
      else
        flash[:error] = t('.error')
      end
      redirect_to spotlight.admin_users_path
    end

    private

    def load_users
      @users ||= ::User.all.reject(&:guest?)
    end

    def load_site
      @site ||= Spotlight::Site.instance
    end

    def create_params
      params.require(:user).permit(:email)
    end

    def update_roles
      Spotlight::Role.create(user_key: create_params[:email], role: 'admin', resource: @site).save
    end
  end
end
