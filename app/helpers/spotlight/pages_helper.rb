module Spotlight
  ##
  # Sir-trevor helpers methods
  module PagesHelper
    ##
    # Override the default #sir_trevor_markdown so we can use
    # a more complete markdown rendered
    def sir_trevor_markdown(text)
      GitHub::Markup.render('.md', text.gsub('<br>', "\n").gsub('<p>', '').gsub('</p>', "\n\n")).html_safe
    end

    def available_index_fields
      fields = blacklight_config.index_fields.map { |k, _v| { key: k, label: index_field_label(nil, k) } }
      fields.unshift(key: document_show_link_field, label: t(:'spotlight.pages.form.title_placeholder')) unless index_fields.include? document_show_link_field

      fields
    end

    def disable_save_pages_button?
      page_collection_name == 'about_pages' && @pages.empty?
    end

    def get_search_widget_search_results(block)
      if block.searches?
        search_results(block.query_params.with_indifferent_access.merge(params), search_params_logic)
      else
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
      when 'feature_pages'
        { 'data-max-depth' => '2',
          'data-expand-btn-HTML' => '',
          'data-collapse-btn-HTML' => '' }
      when 'about_pages'
        { 'data-max-depth' => '1' }
      else
        {}
      end
    end

    def render_contact_email_address(address)
      mail_to address, address
    end
  end
end
