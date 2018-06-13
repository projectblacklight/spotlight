class MigrateCustomFieldSuffixes < ActiveRecord::Migration[5.0]
  # Map custom field sidecar data from using the solr field name
  # to use an application-internal name instead
  def up
    fields = {}

    Spotlight::CustomField.find_each do |f|
      Array(f.solr_field).each do |sf|
        fields[sf] = f
      end
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
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, v| fields.has_key? k }.each do |k, v|
        f.data[fields[k].solr_field.first] = f.data.delete(k)
      end
    end
  end
end
