# frozen_string_literal: true

module Spotlight
  ##
  # Filters exhibits by a free-text query against their title, subtitle, and description.
  # Every word in the query must appear somewhere, in any order, ignoring case.
  class ExhibitSearch
    attr_reader :query, :terms

    # @param [String, nil] html
    # @return [String] the text of the HTML, without tags and with entities decoded
    def self.plain_text(html)
      CGI.unescapeHTML(Rails::Html::FullSanitizer.new.sanitize(html.to_s))
    end

    def initialize(query)
      @query = query.to_s.squish
      @terms = @query.downcase.split
    end

    def active?
      terms.any?
    end

    # Capture literal terms, longest first, so split preserves each complete match for highlighting.
    def highlight_pattern
      @highlight_pattern ||= begin
        longest_first = terms.sort_by { |term| -term.length }
        Regexp.new("(#{Regexp.union(longest_first).source})", Regexp::IGNORECASE)
      end
    end

    # @param [Enumerable<Spotlight::Exhibit>] exhibits
    # @return [Enumerable<Spotlight::Exhibit>] the matching exhibits, or the exhibits unchanged when the query is blank
    def filter(exhibits)
      return exhibits unless active?

      exhibits.select { |exhibit| match?(exhibit) }
    end

    private

    def match?(exhibit)
      text = searchable_text(exhibit)
      terms.all? { |term| text.include?(term) }
    end

    def searchable_text(exhibit)
      [exhibit.title, exhibit.subtitle, self.class.plain_text(exhibit.description)].compact.join("\n").downcase
    end
  end
end
