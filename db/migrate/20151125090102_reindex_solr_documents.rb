class ReindexSolrDocuments < ActiveRecord::Migration
  def up
    ::SolrDocument.find_each do |doc|
      doc.reindex
    end
  rescue => e
    say "Unable to reindex solr index: #{e}"
  end
end