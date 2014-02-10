class Spotlight::Role < ActiveRecord::Base
  belongs_to :exhibit
  belongs_to :user, class_name: '::User', autosave: true
  validate :role, inclusion: { in: %w(admin curate) }

  delegate :user_key, :user_key=, to: :user
end
