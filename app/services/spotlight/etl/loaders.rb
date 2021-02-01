# frozen_string_literal: true

module Spotlight
  module Etl
    module Loaders
      # A loader that just prints the data to $stderr for debugging.
      WarnLoader = lambda do |data, _context|
        warn(JSON.pretty_generate(data))
      end
    end
  end
end
