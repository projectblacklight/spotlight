module Spotlight::User
  extend ActiveSupport::Concern
  included do
    has_many :roles, class_name: 'Spotlight::Role'

    before_create :add_default_roles
  end

  def superadmin?
    admin_roles.where(exhibit_id: nil).any?
  end

  def admin_roles
    roles.where(role: 'admin')
  end

  def add_default_roles
    roles.build role: 'admin' unless self.class.any?
  end

  alias_attribute :user_key, :email

  module ClassMethods
    def find_by_user_key(key)
      find_by email: key
    end
  end
end
