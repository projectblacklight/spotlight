# frozen_string_literal: true

module Spotlight
  module AdminUsers
    # Display site admin role actions for user
    class SiteAdminComponent < ViewComponent::Base
      attr_reader :user

      delegate :current_user, to: :helpers

      def initialize(user:)
        super()
        @user = user
      end
    end
  end
end
