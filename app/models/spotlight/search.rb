class Spotlight::Search < ActiveRecord::Base
  belongs_to :exhibit
  serialize :query_params, Hash
end
