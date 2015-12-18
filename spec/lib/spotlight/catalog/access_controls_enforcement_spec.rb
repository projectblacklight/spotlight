require 'spec_helper'

describe Spotlight::Catalog::AccessControlsEnforcement do
  class MockSearchBuilder < Blacklight::SearchBuilder
    attr_reader :blacklight_params, :scope
    def initialize(blacklight_params, scope)
      @blacklight_params = blacklight_params
      @scope = scope
    end
    include Spotlight::Catalog::AccessControlsEnforcement::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior

    def blacklight_config
      scope.current_exhibit.blacklight_config
    end
  end

  subject { MockSearchBuilder.new blacklight_params, scope }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:scope) { double(current_exhibit: exhibit) }
  let(:solr_request) { Blacklight::Solr::Request.new }
  let(:blacklight_params) { Hash.new }

  describe '.search_params_logic' do
    class MockCatalogController
      include Blacklight::SearchHelper
      include Spotlight::Catalog::AccessControlsEnforcement
    end

    subject { MockCatalogController.new }

    it 'adds the filter to the params logic' do
      expect(subject.search_params_logic).to include :apply_permissive_visibility_filter
    end
  end

  describe '#apply_permissive_visibility_filter' do
    it 'allows curators to view everything' do
      allow(scope).to receive(:can?).and_return(true)
      subject.apply_permissive_visibility_filter(solr_request)
      expect(solr_request.to_hash).to be_empty
    end

    it 'restricts searches to public items' do
      allow(scope).to receive(:can?).and_return(false)

      subject.apply_permissive_visibility_filter(solr_request)
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).to include "-exhibit_#{exhibit.slug}_public_bsi:false"
    end

    it 'does not filter resources to just those created by the exhibit' do
      allow(subject).to receive(:can?).and_return(true)
      subject.apply_permissive_visibility_filter(solr_request)
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
        allow(scope).to receive(:can?).and_return(true)

        subject.apply_exhibit_resources_filter(solr_request)

        expect(solr_request).to include :fq
        expect(solr_request[:fq]).to include "spotlight_exhibit_slug_#{exhibit.slug}_bsi:true"
      end
    end

    context 'with a custom exhibit filter' do
      let(:filter) { exhibit.filters.first_or_initialize }

      before do
        filter.update(field: 'author_ssim', value: 'Coyne, Justin')
      end

      it 'filters resources to just those identified by the exhibit filter' do
        allow(scope).to receive(:can?).and_return(true)

        subject.apply_exhibit_resources_filter(solr_request)

        expect(solr_request).to include :fq
        expect(solr_request[:fq]).to include '{!raw f=author_ssim}Coyne, Justin'
      end
    end
  end
end
