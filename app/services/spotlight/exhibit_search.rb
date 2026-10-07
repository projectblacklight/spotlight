# frozen_string_literal: true

module Spotlight
  ##
  # Filters exhibits by a free-text query against their title, subtitle, and description.
  # Every word in the query must appear somewhere, in any order, ignoring case.
  class ExhibitSearch
    attr_reader :query, :terms

    def initialize(query)
      @query = query.to_s.squish
      @terms = @query.downcase.split
    end

    def active?
      terms.any?
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
      description = CGI.unescapeHTML(html_sanitizer.sanitize(exhibit.description.to_s))
      [exhibit.title, exhibit.subtitle, description].compact.join("\n").downcase
    end

    def html_sanitizer
      @html_sanitizer ||= Rails::Html::FullSanitizer.new
    end
  end
end
