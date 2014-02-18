module Spotlight::SolrDocument::AtomicUpdates

  def reindex
    solr_hash = hash_for_solr_update

    return if solr_hash.length == 1

    blacklight_solr.update params: { commitWithin: 500 }, data: [solr_hash].to_json, headers: { 'Content-Type' => 'application/json'}
  end

  private
  def hash_for_solr_update
    Hash[to_solr.map do |k,v|
      val = if k == :id
        v
      else
        { set: v }
      end

      [k,val]
    end] 
  end
end