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
        val = if k == :id or k == "id"
          v
        else
          { set: v }
        end

        [k,val]
      end] 
    end.reject { |x| x.length <= 1 }
  end
end
