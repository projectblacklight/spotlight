module Spotlight::SolrDocument::AtomicUpdates

  def reindex
    data = hash_for_solr_update

    blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
  end

  private
  def hash_for_solr_update
    data = to_solr
    data = [data] unless data.is_a? Array

    data.map do |doc|
      Hash[doc.map do |k,v|
        val = if k.to_sym == unique_key_field.to_sym
          v
        else
          { set: v }
        end

        [k,val]
      end]
    end.reject { |x| x.length <= 1 }
  end

  def unique_key_field
    if respond_to?(:blacklight_config)
      blacklight_config.solr_document_model.unique_key
    else
      'id'
    end
  end
end
