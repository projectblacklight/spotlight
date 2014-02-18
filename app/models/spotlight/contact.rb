class Spotlight::Contact < ActiveRecord::Base
  belongs_to :exhibit
  scope :published, -> { where(show_in_sidebar: true) }
end
