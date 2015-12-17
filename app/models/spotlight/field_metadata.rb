module Spotlight
  ##
  # Expose Solr index metadata about fields
  class FieldMetadata
    FACET_LIMIT = 20

    attr_reader :exhibit, :repository, :blacklight_config

    def initialize(exhibit, repository, blacklight_config)
      @exhibit = exhibit
      @repository = repository
      @blacklight_config = blacklight_config
    end

    def field(field_name)
      {
        document_count: document_counts.fetch(field_name, 0),
        value_count: terms.fetch(field_name, []).length,
        terms: terms.fetch(field_name, [])
      }
    end

    def search_params
      search_builder.merge(rows: 0, 'facet.limit' => FACET_LIMIT + 1)
    end

    private

    def search_builder_class
      blacklight_config.search_builder_class
    end

    def search_builder
      search_builder_class.new(true, self)
    end

    def solr_response
      @solr_response ||= repository.search(search_params.merge('facet.query' => facet_fields.map { |_key, fields| "#{fields.field}:[* TO *]" },
                                                               'rows' => 0,
                                                               'facet' => true))
    end

    # This gets the number of *documents* with a field
    def document_counts
      @document_count ||= begin
        solr_response.facet_queries.each_with_object({}) do |(k, v), h|
          h[k.split(/:/).first] = v
        end
      end
    end

    def terms
      @terms ||= begin
        solr_response.aggregations.each_with_object({}) do |(facet_name, facet), h|
          h[facet_name] = facet.items.map(&:label)
        end
      end
    end

    def facet_fields
      blacklight_config.facet_fields.reject { |_k, v| v.pivot || v.query }
    end

    alias_method :current_exhibit, :exhibit
  end
end
