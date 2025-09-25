# frozen_string_literal: true

module Spotlight
  module AdminUsers
    # Display email and badge for user
    class EmailComponent < ViewComponent::Base
      attr_reader :user

      def initialize(user:)
        super()
        @user = user
      end

      def user_badge_classes
        classes = []
        classes << 'site-admin' if user.superadmin?
        classes << 'invite-pending' if user.invite_pending?
        classes
      end
    end
  end
end
