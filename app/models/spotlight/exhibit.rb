require 'mail'
module Spotlight
  ##
  # Spotlight exhibit
  class Exhibit < ActiveRecord::Base
    include ExhibitBehavior
  end
end
