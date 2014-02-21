require 'blacklight/utils'

class Blacklight::OpenStructWithHashAccess < OpenStruct
  delegate :to_json, :as_json, to: :to_h
end