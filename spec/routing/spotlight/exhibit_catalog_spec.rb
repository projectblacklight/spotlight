# frozen_string_literal: true

RSpec.describe 'Catalog controller', type: :routing do
  describe 'routing' do
    routes { Spotlight::Engine.routes }

    it 'routes to #show with a format' do
      expect(get('/1/catalog/dq287tq6352.xml')).to route_to('spotlight/catalog#show', exhibit_id: '1', id: 'dq287tq6352', format: 'xml')
    end

    it 'routes to #edit' do
      expect(get('/1/catalog/dq287tq6352/edit')).to route_to('spotlight/catalog#edit', exhibit_id: '1', id: 'dq287tq6352')
    end

    it 'routes to #manifest' do
      expect(get('/1/catalog/1-1/manifest.json')).to route_to('spotlight/catalog#manifest', exhibit_id: '1', id: '1-1', format: 'json')
    end
  end
end
