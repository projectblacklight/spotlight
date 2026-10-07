# frozen_string_literal: true

module Spotlight
  ##
  # Filters exhibits by a free-text query against their (translated) title,
  # subtitle, and description. Every term in the query must match somewhere,
  # in any order, case-insensitively.
  #
  # Matching happens in Ruby rather than SQL because these attributes are
  # translatable and may be served from the I18n backend rather than the
  # exhibits table.
  class ExhibitSearch
    MAX_QUERY_LENGTH = 100
    MAX_TERMS = 10

    attr_reader :query, :terms

    # @param [String, nil] html
    # @return [String] the text content of the HTML, with entities decoded
    def self.plain_text(html)
      Loofah.fragment(html.to_s).text(encode_special_chars: false)
    end

    def initialize(query)
      @query = query.to_s.squish.first(MAX_QUERY_LENGTH)
      @terms = @query.split.uniq(&:downcase).first(MAX_TERMS)
    end

    def active?
      terms.any?
    end

    # @param [Enumerable<Spotlight::Exhibit>] exhibits
    # @return [Enumerable<Spotlight::Exhibit>] the matching exhibits, or the original collection if the search isn't active
    def filter(exhibits)
      return exhibits unless active?

      exhibits.select { |exhibit| match?(exhibit) }
    end

    # @param [ActiveRecord::Relation] relation
    # @return [Kaminari::PaginatableArray, ActiveRecord::Relation] a page of the matching exhibits
    def paginate(relation, page:)
      return relation.page(page) unless active?

      Kaminari.paginate_array(filter(relation.to_a)).page(page).per(Spotlight::Exhibit.default_per_page)
    end

    def match?(exhibit)
      text = searchable_text(exhibit)
      downcased_terms.all? { |term| text.include?(term) }
    end

    private

    def downcased_terms
      @downcased_terms ||= terms.map(&:downcase)
    end

    def searchable_text(exhibit)
      [exhibit.title, exhibit.subtitle, self.class.plain_text(exhibit.description)].compact.join("\n").downcase
    end
  end
end
