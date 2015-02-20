module SirTrevorRails::Blocks
  class FeaturedBrowseCategoriesBlock < SirTrevorRails::Block
    attr_reader :solr_helper

    def with_solr_helper solr_helper
      @solr_helper = solr_helper
    end

    def display_item_counts?
      as_json[:data][:"display-item-counts"]
    end

    def block_objects
      @block_objects ||= sorted_browse_categories.map do |category|
        OpenStruct.new(
          browse_category: category,
          count: item_counts_for_category(category)
        )
      end
    end

    private

    def sorted_browse_categories
      browse_categories.sort do |a,b|
        order_data.index(a.slug) <=> order_data.index(b.slug)
      end
    end

    def order_data
      data.select do |k,_|
        k =~ /^weight-\S+/
      end.compact.sort_by{|_,v| v}.map do |k,_|
        k[/^weight-(\S+)/]; $1
      end
    end

    def browse_categories
      @browse_categories ||= parent.exhibit.searches.select do |search|
        category_slugs.include?(search.slug)
      end
    end

    def item_counts_for_category(category)
      solr_helper.get_search_results(category.query_params).first["response"]["numFound"]
    end

    def data
      as_json[:data].stringify_keys
    end

    def slug_data
      data.except(:"display-item-counts").except do |k,_|
        k =~ /^weight/
      end
    end

    def category_slugs
      @category_ids ||= slug_data.map do |slug, enabled|
        slug if enabled
      end.compact
    end

  end
end