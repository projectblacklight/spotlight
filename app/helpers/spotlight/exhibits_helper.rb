# frozen_string_literal: true

module Spotlight
  ##
  # Helpers for the exhibits index
  module ExhibitsHelper
    # @return [Spotlight::ExhibitSearch]
    def exhibit_search
      @exhibit_search ||= Spotlight::ExhibitSearch.new(params[:q])
    end

    # The status message announced to screen readers (and shown visually) after a search.
    #
    # @param [Integer] count the number of matching exhibits
    # @param [Symbol, nil] tab the tab the exhibits are listed in (:published, :unpublished, or :user),
    #   or nil when the page has no tabs
    # @return [String, nil]
    def exhibit_search_status(count, tab: nil, search: exhibit_search)
      return t('spotlight.exhibits.search.status.all') if !search.active? && params.key?(:q)
      return unless search.active?

      t("spotlight.exhibits.search.status.#{tab || :matches}", count:, query: search.query)
    end

    # The names of the tags that have at least one exhibit matching the search,
    # so tags without any can be disabled.
    #
    # @param [ActiveRecord::Relation] exhibits
    # @param [Spotlight::ExhibitSearch] search
    # @return [Set<String>, nil] nil when the search isn't active
    def exhibit_search_matching_tag_names(exhibits, search = exhibit_search)
      return unless search.active?

      search.filter(exhibits.includes(:tags)).flat_map { |exhibit| exhibit.tags.map(&:name) }.to_set
    end

    # Wrap each occurrence of the current exhibit search terms in a <mark>,
    # escaping the rest of the text.
    #
    # @param [String, nil] text plain text (not HTML)
    # @param [Spotlight::ExhibitSearch] search
    # @return [ActiveSupport::SafeBuffer, String, nil]
    def highlight_exhibit_search_terms(text, search = exhibit_search)
      return text if text.blank? || !search.active?

      pattern = Regexp.union(search.terms.sort_by { |term| -term.length }.map { |term| Regexp.new(Regexp.escape(term), Regexp::IGNORECASE) })

      safe_join(text.split(/(#{pattern})/).each_with_index.map { |part, index| index.odd? ? tag.mark(part) : part })
    end
  end
end
