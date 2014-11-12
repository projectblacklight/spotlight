require 'spec_helper'

describe Spotlight::Catalog::AccessControlsEnforcement do
  class MockCatalogController
    include Blacklight::SolrHelper
    include Spotlight::Catalog::AccessControlsEnforcement
  end

  subject { MockCatalogController.new }
  let(:solr_request) { Blacklight::Solr::Request.new }

  before do
    allow(subject).to receive_messages(current_exhibit: FactoryGirl.create(:exhibit))
  end

  describe "#apply_permissive_visibility_filter" do
    it "should add the filter to the params logic" do
      expect(subject.solr_search_params_logic).to include :apply_permissive_visibility_filter 
    end

    it "should allow curators to view everything" do
      allow(subject).to receive(:can?).and_return(true)
      subject.send(:apply_permissive_visibility_filter, solr_request, {})
      expect(solr_request.to_hash).to be_empty
    end

    it "should restrict searches to public items" do
      allow(subject).to receive(:can?).and_return(false)

      subject.send(:apply_permissive_visibility_filter, solr_request, {})
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).to include "-exhibit_1_public_bsi:false"
    end
  end
end
