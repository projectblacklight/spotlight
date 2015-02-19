require 'roar/decorator'
require 'roar/json'
module Spotlight
  class PageRepresenter < Roar::Decorator
    include Roar::JSON
    (Spotlight::Page.attribute_names - ['id', 'slug', 'scope', 'exhibit_id', 'parent_page_id', 'content']).each do |prop|
      property prop
    end

    property :content, exec_context: :decorator

    def content
      # get the sir-trevor objects as JSON, and then turn it into a string
      represented.content.as_json.to_json
    end

    def content= content
      represented.content = content
    end
  end

  class NestedPageRepresenter < PageRepresenter
    collection :child_pages, class: Spotlight::FeaturePage, extend: NestedPageRepresenter
  end
end