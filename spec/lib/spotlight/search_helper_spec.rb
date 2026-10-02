# frozen_string_literal: true

RSpec.describe Spotlight::SearchHelper do
  subject(:helper) { helper_class.new(blacklight_config, search_state) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:search_state) { Blacklight::SearchState.new({ q: 'xyz' }, blacklight_config) }

  let(:helper_class) do
    Class.new do
      include Spotlight::SearchHelper

      attr_reader :blacklight_config, :search_state

      def initialize(blacklight_config, search_state)
        @blacklight_config = blacklight_config
        @search_state = search_state
      end
    end
  end

  describe '#search_service' do
    it 'provides a search service in a non-controller class' do
      expect(helper.search_service).to be_a Blacklight::SearchService
    end

    it 'passes the current ability to the search service when available' do
      ability = instance_double(Ability)
      helper.define_singleton_method(:current_ability) { ability }

      expect(helper.search_service.context).to eq(current_ability: ability)
    end
  end

  describe '.search_service_class' do
    let(:custom_search_service) { Class.new(Blacklight::SearchService) }

    it 'keeps a search_service_class inherited from a Blacklight::Catalog controller' do
      # Spotlight::CatalogController subclasses the host app's CatalogController this way
      parent = Class.new(ApplicationController) { include Blacklight::Catalog }
      parent.search_service_class = custom_search_service
      child = Class.new(parent) { include Spotlight::SearchHelper }

      expect(child.search_service_class).to eq custom_search_service
    end
  end
end
