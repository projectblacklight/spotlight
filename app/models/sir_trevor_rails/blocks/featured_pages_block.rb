module SirTrevorRails::Blocks
  class FeaturedPagesBlock < SirTrevorRails::Block

    def pages
      @pages ||= parent.exhibit.feature_pages.published.where(id: page_ids)
    end

    private

    def page_ids
      as_json[:data].select { |k,v| k =~ /^page-grid-id_\d+$/ }.values.reject(&:blank?)
    end

  end
end