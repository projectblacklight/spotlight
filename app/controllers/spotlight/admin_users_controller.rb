# frozen_string_literal: true

module Spotlight
  ##
  # A controller to handle the adminstration of site admin users
  class AdminUsersController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :load_site
    load_and_authorize_resource :site, class: 'Spotlight::Site'

    def index; end

    def create
      if update_roles
        Spotlight::InviteUsersService.call(resource: @site)
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
    
    def mask_role
       url = request.referrer
       role = site_admin_role
       if (params[:role] && !role.nil?)
         #Set the role in the db
         #First role since the only people that mask are Site Admins
         if (Spotlight::Role::ROLES.include?(params[:role]))
           role.update ({:role_mask => params[:role]})
         end   
       end
       if (!url.nil?)
         #Redirect to the previous url
         redirect_to url
       else
         redirect_to main_app.root_url
       end
     end
     
     def clear_mask_role
       url = request.referrer
       role = site_admin_role
       if (!role.nil?)
         role.update({:role_mask => nil})
       end
       if (!url.nil?)
         #Redirect to the previous url
         redirect_to url
       else
         redirect_to main_app.root_url
       end
     end

    private
    
    def site_admin_role
      current_user.roles.where(role: 'admin', resource: Spotlight::Site.instance).first
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
