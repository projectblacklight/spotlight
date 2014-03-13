class Spotlight::Contact < ActiveRecord::Base
  belongs_to :exhibit
  scope :published, -> { where(show_in_sidebar: true) }
  default_scope { order("weight ASC") }
  
  extend FriendlyId
  friendly_id :name, use: [:slugged,:scoped,:finders], scope: :exhibit

  protected
  def should_generate_new_friendly_id?
    name_changed?
  end

end
