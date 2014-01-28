class Spotlight::Role < ActiveRecord::Base
  belongs_to :exhibit
  belongs_to :user
end
