module Spotlight::User
  extend ActiveSupport::Concern
  included do
    has_many :roles, class_name: 'Spotlight::Role'
  end
end
