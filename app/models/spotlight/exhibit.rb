class Spotlight::Exhibit < ActiveRecord::Base
  has_many :roles
  serialize :facets, Array

end
