require 'spec_helper'

describe Spotlight::SolrDocument::AtomicUpdates, :type => :model do
  let(:blacklight_solr) { double }
  subject do
    ::SolrDocument.new.extend(Spotlight::SolrDocument::AtomicUpdates)
  end

  before do
    allow(subject).to receive_messages(blacklight_solr: blacklight_solr)
  end

  describe "#reindex" do
    before do
      allow(subject).to receive_messages(to_solr: { id: 'doc_id', a: 1, b: 2 })
    end

    it "should send an atomic update request" do
      expect(blacklight_solr).to receive(:update).with(params: { commitWithin: 500 }, data: [{id: 'doc_id', a: { set: 1 }, b: { set: 2 }}].to_json, headers: { 'Content-Type' => 'application/json'})
      subject.reindex
    end

    it "should cowardly refuse to index a document if the only value is an id" do
      allow(subject).to receive_messages(to_solr: { id: 'doc_id' })
      expect(blacklight_solr).not_to receive(:update)
      subject.reindex
    end
  end
end