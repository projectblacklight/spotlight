module Spotlight::User
  extend ActiveSupport::Concern
  included do
    has_many :roles, class_name: 'Spotlight::Role'

  end

  def admin_roles
    roles.where(role: 'admin')
  end

  alias_attribute :user_key, :email
end
