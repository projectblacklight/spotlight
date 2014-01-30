class Spotlight::Search < ActiveRecord::Base
  serialize :query_params, Hash
end
