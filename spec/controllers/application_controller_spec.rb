require 'spec_helper'

describe ApplicationController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  it { is_expected.to be_a_kind_of Spotlight::Controller }

  describe 'exhibit-specific routing' do
    context 'with a current exhibit' do
      before do
        allow(controller).to receive(:current_exhibit).and_return(exhibit)
      end

      describe '#search_action_url' do
        it 'is a path within the current exhibit' do
          expected = { controller: 'spotlight/catalog', action: 'index', exhibit_id: exhibit.slug }
          expect(get: controller.search_action_url(only_path: true).gsub('/spotlight', '')).to route_to expected
        end
      end

      describe '#search_facets_url' do
        it 'is a path within the current exhibit' do
          expected = { controller: 'spotlight/catalog', action: 'facet', id: 'some-facet', exhibit_id: exhibit.slug }
          expect(get: controller.search_facet_url(id: 'some-facet', only_path: true).gsub('/spotlight', '')).to route_to expected
        end
      end
    end
  end
end
