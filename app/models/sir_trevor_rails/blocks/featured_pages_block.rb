module SirTrevorRails::Blocks
  class FeaturedPagesBlock < SirTrevorRails::Block

    def page_options id
      (items.find { |x| x[:id] == id }) || {}
    end

    def pages
      ids = items.map { |v| v[:id] }
      @pages ||= parent.exhibit.pages.published.where(slug: ids).sort { |a,b| order.index(a.id) <=> order.index(b.id) }
    end

    def pages?
      !pages.empty?
    end

    def items
      item.values.select { |x| x[:display] == "true" }
    end

    def order
      items.sort_by { |x| x[:weight] }.map { |x| x[:id] }
    end
  end
end