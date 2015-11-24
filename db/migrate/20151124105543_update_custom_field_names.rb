class UpdateCustomFieldNames < ActiveRecord::Migration
  def up
    fields = {}

    Spotlight::CustomField.find_each do |f|
      f.update(field: f.send(:field_name))
      fields[f.solr_field] = f
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, v| fields.has_key? k }.each do |k, v|
        f.data[fields[k].send(:field_name)] = f.data.delete(k)
      end
    end
  end

  def down
    fields = {}

    Spotlight::CustomField.find_each do |f|
      fields[f.field] = f
      f.update(field: f.send(:solr_field))
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, v| fields.has_key? k }.each do |k, v|
        f.data[fields[k].send(:solr_field)] = f.data.delete(k)
      end
    end
  end
end