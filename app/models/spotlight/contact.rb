class Spotlight::Contact < ActiveRecord::Base
  belongs_to :exhibit
  scope :published, -> { where(show_in_sidebar: true) }
  default_scope { order("weight ASC") }
end
