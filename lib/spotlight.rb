
module Spotlight
  extend ActiveSupport::Autoload
  autoload :Config
  autoload :Base
  autoload :Controller
  autoload :Catalog
  autoload :DocumentPresenter

  module Indexer
    extend ActiveSupport::Autoload
    autoload :LocalWriter
  end

  def self.index_writer
    @@index_writer ||= config.index_writer.new
  end
end

require 'spotlight/engine'
