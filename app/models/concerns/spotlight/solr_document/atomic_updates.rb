module Spotlight::SolrDocument::AtomicUpdates

  def reindex
    data = hash_for_solr_update(to_solr)

    blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
  end

  private
  def hash_for_solr_update data
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
    begin
      return self.class.unique_key
    rescue
      return 'id'
    end
  end
end
