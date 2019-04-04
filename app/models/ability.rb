# frozen_string_literal: true

##
# Default Cancan ability implementation; this should be overridden by
# downstream application
class Ability
  include Spotlight::Ability
end
