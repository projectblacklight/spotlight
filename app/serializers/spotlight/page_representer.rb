require 'roar/decorator'
require 'roar/json'
module Spotlight
  class PageRepresenter < Roar::Decorator
    include Roar::JSON
    (Spotlight::Page.attribute_names - ['id', 'scope', 'exhibit_id', 'parent_page_id', 'content']).each do |prop|
      property prop
    end

    property :content, exec_context: :decorator

    def content
      # get the sir-trevor objects as JSON.
      represented.content.as_json
    end

    def content= content
      represented.content = content
    end
  end

  class NestedPageRepresenter < PageRepresenter
    collection :child_pages, parse_strategy: lambda { |fragment, i, options| options.represented.child_pages.find_or_initialize_by(slug: fragment['slug']) }, class: Spotlight::FeaturePage, extend: NestedPageRepresenter
  end
end