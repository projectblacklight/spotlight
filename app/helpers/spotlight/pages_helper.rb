module Spotlight
  module PagesHelper
    def sir_trevor_markdown text
      GitHub::Markup.render(".md", text.gsub("<br>", "\n").gsub("<p>", "").gsub("</p>", "\n\n")).html_safe
    end
    def has_title? document
      document_heading(document) != document.id
    end
    def item_grid_block_with_documents(block)
      block_objects = item_grid_block_objects(block)
      ids = item_grid_block_ids(block)
      documents = fetch(ids).last
      block_objects.each do |object|
        if (doc = documents.find{ |d| d[:id] == object[:id] }).present?
          object[:solr_document] = doc
        end
      end
    end
    def item_grid_block_objects(block)
      objects = []
      block.each do |key, value|
        if value.present? and key.include?("item-grid-id")
          if (display = block[key.gsub("-id", "-display")])
            objects << {id: value,
                        display: display,
                        thumbnail: block[key.gsub("-id", "-thumbnail")]}
          end
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
          document_heading(document)
        else
          render_index_field_value document, block[key]
        end
      end
    end
    def disable_save_pages_button?
      page_collection_name == "about_pages" && @pages.empty?
    end
    def get_search_widget_search_results block
      begin
        get_search_results(block.query_params.with_indifferent_access.merge(params))
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
    def render_contact_email_address(address)
      mail_to address, address
    end
  end
end
