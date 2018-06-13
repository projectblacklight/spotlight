class UpdateCustomFieldNames < ActiveRecord::Migration[4.2]
  def up
    fields = {}

    Spotlight::CustomField.find_each do |f|
      f.update(field: f.field)
      fields[f.solr_field] = f
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, v| fields.has_key? k }.each do |k, v|
        f.data[fields[k].field] = f.data.delete(k)
      end
    end
  end

  def down
    fields = {}

    Spotlight::CustomField.find_each do |f|
      fields[f.field] = f
      f.update(field: f.solr_field.first)
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, v| fields.has_key? k }.each do |k, v|
        field = fields[k]
        suffix = case field.field_type
                 when 'vocab'
                   Spotlight::Engine.config.solr_fields.string_suffix
                 else
                   Spotlight::Engine.config.solr_fields.text_suffix
                 end
        solr_field = Array(field.solr_field).select { |x| x.ends_with? suffix }
        f.data[solr_field] = f.data.delete(k) if solr_field
      end
    end
  end
end
