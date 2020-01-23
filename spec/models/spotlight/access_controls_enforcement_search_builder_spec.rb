# frozen_string_literal: true

describe Spotlight::AccessControlsEnforcementSearchBuilder do
  class MockSearchBuilder < Blacklight::SearchBuilder
    attr_reader :blacklight_params, :scope
    def initialize(blacklight_params, scope)
      @blacklight_params = blacklight_params
      @scope = scope
    end
    include Spotlight::AccessControlsEnforcementSearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior

    def blacklight_config
      scope.current_exhibit.blacklight_config
    end
  end

  subject { MockSearchBuilder.new blacklight_params, scope }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:scope) { double(current_exhibit: exhibit, context: { current_ability: current_ability }) }
  let(:current_ability) { instance_double(Ability) }
  let(:solr_request) { Blacklight::Solr::Request.new }
  let(:blacklight_params) { {} }

  describe '#apply_permissive_visibility_filter' do
    it 'allows curators to view everything' do
      allow(current_ability).to receive(:can?).and_return(true)
      subject.apply_permissive_visibility_filter(solr_request)
      expect(solr_request.to_hash).to be_empty
    end

    it 'restricts searches to public items' do
      allow(current_ability).to receive(:can?).and_return(false)

      subject.apply_permissive_visibility_filter(solr_request)
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).to include "-exhibit_#{exhibit.slug}_public_bsi:false"
    end

    it 'does not filter resources to just those created by the exhibit' do
      allow(current_ability).to receive(:can?).and_return(true)
      subject.apply_permissive_visibility_filter(solr_request)
      expect(solr_request).to include :fq
      expect(solr_request[:fq]).not_to include "{!term f=spotlight_exhibit_slug_#{exhibit.slug}_bsi}true"
    end
  end

  describe '#apply_exhibit_resources_filter' do
    context 'with filter_resources_by_exhibit' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
      end

      it 'filters resources to just those created by the exhibit' do
        allow(current_ability).to receive(:can?).and_return(true)

        subject.apply_exhibit_resources_filter(solr_request)

        expect(solr_request).to include :fq
        expect(solr_request[:fq]).to include "{!term f=spotlight_exhibit_slug_#{exhibit.slug}_bsi}true"
      end
    end

    context 'with a custom exhibit filter' do
      let(:filter) { exhibit.filters.first_or_initialize }

      before do
        filter.update(field: 'author_ssim', value: 'Coyne, Justin')
      end

      it 'filters resources to just those identified by the exhibit filter' do
        allow(current_ability).to receive(:can?).and_return(true)

        subject.apply_exhibit_resources_filter(solr_request)

        expect(solr_request).to include :fq
        expect(solr_request[:fq]).to include '{!term f=author_ssim}Coyne, Justin'
      end
    end
  end
end
