module SirTrevorRails::Blocks
  class SearchResultsBlock < SirTrevorRails::Block
    def query_params
      search.query_params
    end

    def search
      @search ||= if slug
        parent.exhibit.searches.find_by!(slug: slug)
      elsif search_id = send(:'searches-options')
        parent.exhibit.searches.find(search_id)
      end
    end
  end
end