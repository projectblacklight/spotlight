module Spotlight
  ##
  # Expose Solr index metadata about fields
  class FieldMetadata
    attr_reader :repository, :blacklight_config
    def initialize(repository, blacklight_config)
      @repository = repository
      @blacklight_config = blacklight_config
    end

    def field(field_name)
      {
        document_count: document_counts.fetch(field_name, 0),
        value_count: fields.fetch(field_name, {}).fetch('distinct', 0),
        terms: fields.fetch(field_name, {}).fetch('topTerms', [])
      }
    end

    private

    def luke
      @luke ||= repository.send_and_receive('admin/luke', fl: '*', 'json.nl' => 'map')
    end

    def fields
      luke['fields']
    end

    # This gets the number of *documents* with a field
    def document_counts
      @document_count ||= begin
        solr_resp = repository.search('facet.query' => facet_fields.map { |_key, fields| "#{fields.field}:[* TO *]" },
                                      'rows' => 0,
                                      'facet' => true)

        solr_resp['facet_counts']['facet_queries'].each_with_object({}) do |(k, v), h|
          h[k.split(/:/).first] = v
        end
      end
    end

    def facet_fields
      blacklight_config.facet_fields.reject { |_k, v| v.pivot || v.query }
    end
  end
end
