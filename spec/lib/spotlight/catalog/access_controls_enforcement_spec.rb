require 'spec_helper'

describe Spotlight::Catalog::AccessControlsEnforcement do
  class MockCatalogController
    include Blacklight::SearchHelper
    include Spotlight::Catalog::AccessControlsEnforcement

    def blacklight_config
      @blacklight_config ||= Blacklight::Configuration.new
    end
  end

  subject { MockCatalogController.new }
  let(:solr_request) { Blacklight::Solr::Request.new }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  before do
    allow(subject).to receive_messages(current_exhibit: exhibit)
  end

  describe '#apply_permissive_visibility_filter' do
    it 'adds the filter to the params logic' do
      expect(subject.search_params_logic).to include :apply_permissive_visibility_filter
    end

    it 'allows curators to view everything' do
      allow(subject).to receive(:can?).and_return(true)
      subject.send(:apply_permissive_visibility_filter, solr_request, {})
      expect(solr_request.to_hash).to be_empty
    end

    it 'restricts searches to public items' do
      allow(subject).to receive(:can?).and_return(false)

      subject.send(:apply_permissive_visibility_filter, solr_request, {})
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).to include '-exhibit_1_public_bsi:false'
    end

    it 'does not filter resources to just those created by the exhibit' do
      allow(subject).to receive(:can?).and_return(true)
      subject.send(:apply_permissive_visibility_filter, solr_request, {})
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).not_to include "spotlight_exhibit_slug_#{exhibit.slug}_bsi:true"
    end
  end

  describe '#apply_exhibit_resources_filter' do
    context 'with filter_resources_by_exhibit' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
      end

      it 'filters resources to just those created by the exhibit' do
        allow(subject).to receive(:can?).and_return(true)
        subject.send(:apply_exhibit_resources_filter, solr_request, {})
        expect(solr_request).to include :fq
        expect(solr_request[:fq]).to include "spotlight_exhibit_slug_#{exhibit.slug}_bsi:true"
      end
    end
  end
end
