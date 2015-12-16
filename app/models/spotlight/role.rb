module Spotlight
  ##
  # Exhibit authorization roles
  class Role < ActiveRecord::Base
    ROLES = %w(admin curator)
    belongs_to :resource, polymorphic: true
    belongs_to :user, class_name: Spotlight::Engine.config.user_class, autosave: true
    validates :role, inclusion: { in: ROLES }
    validates :user_key, presence: true
    validate :user_must_exist, if: -> { user_key.present? }
    validate :user_must_be_unique, if: :user

    def user_key
      if user
        @user_key = user.user_key
      else
        @user_key
      end
    end

    # setting user key causes the user to get set
    def user_key=(key)
      @user_key = key
      self.user ||= Spotlight::Engine.user_class.find_by_user_key(key)
      user.user_key = key if user
    end

    protected

    def user_must_exist
      errors.add(:user_key, 'User must sign up first.') unless user.present?
    end

    # This is just like
    #    validates :user, uniqueness: { scope: :exhibit}
    # but it puts the error message on the user_key instead of user so that the form will render correctly
    def user_must_be_unique
      errors.add(:user_key, 'already a member of this exhibit') if Spotlight::Role.where(resource: resource, user: user).where.not(id: id).any?
    end
  end
end
