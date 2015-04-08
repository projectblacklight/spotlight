require 'roar/decorator'
require 'roar/json'
module Spotlight
  ##
  # Serialize an exhibit page
  class PageRepresenter < Roar::Decorator
    include Roar::JSON
    (Spotlight::Page.attribute_names - %w(id scope exhibit_id parent_page_id content)).each do |prop|
      property prop
    end

    property :content, exec_context: :decorator

    def content
      # get the sir-trevor objects as JSON.
      represented.content.as_json
    end

    delegate :content=, to: :represented
  end

  ##
  # Serialize the page hierarchy (e.g. for Feature pages)
  class NestedPageRepresenter < PageRepresenter
    collection :child_pages, parse_strategy: ->(fragment, _i, options) { options.represented.child_pages.find_or_initialize_by(slug: fragment['slug']) },
                             class: Spotlight::FeaturePage,
                             extend: NestedPageRepresenter
  end
end
