# frozen_string_literal: true

module Spotlight
  module AdminUsers
    # Display all exhibit roles for a user
    class ExhibitRolesComponent < ViewComponent::Base
      attr_reader :user

      def initialize(user:)
        super()
        @user = user
      end

      def sorted_exhibit_roles
        @sorted_exhibit_roles ||= user.all_exhibit_roles.sort_by { |r| [r.role, r.resource.title] }
      end
    end
  end
end
