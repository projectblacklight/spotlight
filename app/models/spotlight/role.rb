class Spotlight::Role < ActiveRecord::Base
  belongs_to :exhibit
  belongs_to :user
  validate :role, inclusion: { in: %w(admin curate) }
end
