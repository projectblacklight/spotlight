module Spotlight
  module Concerns
    ###
    # Mixin to be included into controllers that provides an action which
    # allows admins and curators to invite users and assign them a role.
    module UserInvitable
      def invite
        # skip_invitation stops the immediate delivery of the invitation
        user = Spotlight::Engine.user_class.invite!(email: invite_params[:user], skip_invitation: true)
        role = Spotlight::Role.create(resource: exhibit_or_site, user: user, role: invite_params[:role])
        if role.save
          user.deliver_invitation # now deliver it when we have saved the role
          redirect_back fallback_location: fallback_location, notice: t(:'helpers.submit.invite.invited')
        else
          redirect_back fallback_location: fallback_location, alert: t(:'helpers.submit.role.batch_error', count: 1)
        end
      end

      protected

      def invite_params
        params.permit(:user, :role)
      end

      def exhibit_or_site
        current_exhibit || @site
      end

      def fallback_location
        if current_exhibit
          spotlight.exhibit_roles_path(current_exhibit)
        else
          spotlight.admin_users_path
        end
      end
    end
  end
end
