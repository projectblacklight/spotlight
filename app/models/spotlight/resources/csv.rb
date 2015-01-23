require 'csv'

module Spotlight
  class Resources::Csv < Spotlight::Resource
    mount_uploader :url, Spotlight::CsvUploader

    # we want to do this before reindexing
    after_save :update_exhibit_specific_fields, if: :url_changed?, prepend: true

    def to_solr
      store_url! # so that #url doesn't return the tmp directory
      
      base_doc = super
      
      base_doc.merge!(
        :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_url#{Spotlight::Engine.config.solr_fields.string_suffix}" => url.url
      )
      
      csv.map do |row|
        h = base_doc.merge(solr_document_model.new(base_doc).to_solr)
        row.each do |k,v|
          if label_to_field[k]
            h[label_to_field[k]] ||= []
            h[label_to_field[k]] << v
          end
        end
        h
      end
    end

    def label_to_field
      @label_to_field ||= begin
        label_to_field = {}
        label_to_field['id'] ||= solr_document_model.unique_key
        label_to_field[title_field_name] ||= exhibit.blacklight_config.index.title_field
        label_to_field[public_field_name] ||= Spotlight::SolrDocument.visibility_field(exhibit)
        label_to_field.merge! Hash[exhibit.blacklight_config.index_fields.map { |k,v| [v.label, v.field]}]
        label_to_field.merge! Hash[exhibit.blacklight_config.facet_fields.map { |k,v| [v.label, v.field]}]
        label_to_field
      end
    end

    def csv options={ headers: true }, &block
      CSV.new File.open(url.path, 'r'), options
    end

    private
    def update_exhibit_specific_fields

      csv.map do |row|
        sidecar_updates = {}
        row.each do |label,v|
          if custom_fields[label]
            sidecar_updates[custom_fields[label]] = v
          end
        end

        unless row[public_field_name].blank? and sidecar_updates.empty?
          sidecar = solr_document_model.new(id: row['id']).sidecar(exhibit)
          sidecar.update(
            public: row[public_field_name],
            data: sidecar.data.merge(sidecar_updates)
          )
        end
      end
    end

    def custom_fields
      Hash[exhibit.custom_fields.map { |f| [f.label, f.field] }]
    end

    def title_field_name
      "Title"
    end

    def public_field_name
      "Public"
    end
  end
end
