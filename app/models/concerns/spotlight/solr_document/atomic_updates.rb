module Spotlight::SolrDocument::AtomicUpdates

  def reindex
    blacklight_solr.update data: hash_for_solr_update.to_json, headers: { 'Content-Type' => 'application/json'}
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