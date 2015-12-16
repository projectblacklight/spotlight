module Spotlight
  ##
  # Spotlight user mixins for roles
  module User
    extend ActiveSupport::Concern
    included do
      has_many :roles, class_name: 'Spotlight::Role', dependent: :destroy
      has_many :exhibits, class_name: 'Spotlight::Exhibit', through: :roles, source: 'resource', source_type: 'Spotlight::Exhibit'

      before_create :add_default_roles
    end

    def superadmin?
      roles.where(role: 'admin', resource: Spotlight::Site.instance).any?
    end

    def exhibit_roles
      roles.where(resource_type: 'Spotlight::Exhibit')
    end

    def admin_roles
      exhibit_roles.where(role: 'admin')
    end

    def add_default_roles
      roles.build role: 'admin', resource: Spotlight::Site.instance unless self.class.any?
    end

    def invite_pending?
      invited_to_sign_up? && !invitation_accepted?
    end

    alias_attribute :user_key, :email

    ##
    # Class-level user mixins
    module ClassMethods
      def find_by_user_key(key)
        find_by email: key
      end
    end
  end
end
