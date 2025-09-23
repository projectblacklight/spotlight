# frozen_string_literal: true

module Spotlight
  ##
  # Helper for admin_users views
  module AdminUsersHelper
    def sorted_exhibit_roles(user)
      user.all_exhibit_roles.sort_by { |r| [r.role, r.resource.title] }
    end

    def user_badge_classes(user)
      classes = []
      classes << 'site-admin' if user.superadmin?
      classes << 'invite-pending' if user.invite_pending?
      classes.join(' ')
    end
  end
end
