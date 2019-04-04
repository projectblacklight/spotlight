# frozen_string_literal: true

module Spotlight
  ##
  # A simple service to invite any users who where created by an invitation but it was never sent.
  # This is done because the associated information between the resource, the role, and the user
  # need to be persisted in order to generate the appropriate content in the invitation email.
  class InviteUsersService
    def self.call(resource:)
      resource.roles.includes(:user).each do |role|
        user = role.user

        user.deliver_invitation if user.created_by_invite? && user.invitation_sent_at.blank?
      end
    end
  end
end
