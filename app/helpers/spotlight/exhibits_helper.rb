# frozen_string_literal: true

module Spotlight
  ##
  # Helpers for the exhibits index
  module ExhibitsHelper
    # Wrap each match of the exhibit search in a <mark>, escaping the rest of the text
    def highlight_exhibit_search(text, search)
      return text if text.blank? || !search.active?

      # Longest first, so a word that contains another word from the query is marked whole
      terms = search.terms.sort_by { |term| -term.length }
      pattern = Regexp.new(Regexp.union(terms).source, Regexp::IGNORECASE)

      safe_join(text.split(/(#{pattern})/).each_with_index.map { |part, index| index.odd? ? tag.mark(part) : part })
    end

    # The message that the live filter gives to screen readers after it updates a tab
    def exhibit_search_status(search, count)
      return t('spotlight.exhibits.index.search_status.all') unless search.active?

      t('spotlight.exhibits.index.search_status.matches', count:)
    end
  end
end
