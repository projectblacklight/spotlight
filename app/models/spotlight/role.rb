class Spotlight::Role < ActiveRecord::Base
  belongs_to :exhibit
  belongs_to :user, class_name: '::User', autosave: true
  validates :role, inclusion: { in: %w(admin curate) }
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
  def user_key= key
    @user_key = key
    self.user ||= User.find_by_user_key(key)
    if user
      user.user_key = key
    end
  end

  protected

  def user_must_exist
    unless user.present?
      errors.add(:user_key, "User must sign up first.")
    end
  end

  # This is just like 
  #    validates :user, uniqueness: { scope: :exhibit}
  # but it puts the error message on the user_key instead of user so that the form will render correctly
  def user_must_be_unique
    if Spotlight::Role.where(exhibit_id: exhibit_id, user_id: user.id).where.not(id: id).any? 
      errors.add(:user_key, "already a member of this exhibit")
    end
  end

end
