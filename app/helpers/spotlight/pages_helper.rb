module Spotlight
  module PagesHelper
    def has_title? document
      document_heading(document) != document.id
    end
    def item_grid_block_objects(block)
      objects = []
      block.each do |key, value|
        if value.present? and key.include?("item-grid-id")
          objects << {id: value, display: (block[key.gsub("-id", "-display")])}
        end
      end
      objects
    end
    def item_grid_block_ids(block)
      item_grid_block_objects(block).map do |object|
        object[:id] if object[:display]
      end.compact
    end
    def multi_up_item_grid_caption(block, document, type='primary')
      key = "item-grid-#{type}-caption-field"
      if block[key].present?
        if block[key] == 'spotlight_title_field'
          return document_heading(document)
        else
          return safe_join(Array(document[block[key]]), ", ")
        end
      end
    end
    def disable_save_pages_button?
      page_collection_name == "about_pages" && @pages.empty?
    end
    def get_search_widget_search_results sir_trevor_json
      begin
        search = Spotlight::Search.find(sir_trevor_json['searches-options'])
        get_search_results(search.query_params.with_indifferent_access.merge(params))
      rescue ActiveRecord::RecordNotFound
        []
      end
    end
    def nestable_data_attributes(type)
      nestable_data_attributes_hash(type).map do |attr, val|
        "#{attr}='#{val}'"
      end.join(' ')
    end
    def nestable_data_attributes_hash(type)
      case type
      when "feature_pages"
        {:"data-max-depth" => '2',
         :"data-expand-btn-HTML" => '',
         :"data-collapse-btn-HTML" => ''}
      when "about_pages"
        {:"data-max-depth" => '1'}
      else
        {}
      end
    end
  end
end
