require 'spec_helper'

module Spotlight
  describe 'FeaturePagesController and AboutPagesController', type: :routing do
    describe 'routing' do
      routes { Spotlight::Engine.routes }

      it 'routes to #index' do
        expect(get('/1/feature')).to route_to('spotlight/feature_pages#index', exhibit_id: '1')
        expect(get('/1/about')).to route_to('spotlight/about_pages#index', exhibit_id: '1')
      end

      it 'routes to #new' do
        expect(get('/1/feature/new')).to route_to('spotlight/feature_pages#new', exhibit_id: '1')
        expect(get('/1/about/new')).to route_to('spotlight/about_pages#new', exhibit_id: '1')
      end

      it 'routes to #show' do
        expect(get('/1/feature/2')).to route_to('spotlight/feature_pages#show', id: '2', exhibit_id: '1')
        expect(get('/1/about/2')).to route_to('spotlight/about_pages#show', id: '2', exhibit_id: '1')
      end

      it 'routes to #edit' do
        expect(get('/1/feature/2/edit')).to route_to('spotlight/feature_pages#edit', id: '2', exhibit_id: '1')
        expect(get('/1/about/2/edit')).to route_to('spotlight/about_pages#edit', id: '2', exhibit_id: '1')
      end

      it 'routes to #create' do
        expect(post('/1/feature')).to route_to('spotlight/feature_pages#create', exhibit_id: '1')
        expect(post('/1/about')).to route_to('spotlight/about_pages#create', exhibit_id: '1')
      end

      it 'routes to #update' do
        expect(put('/1/feature/2')).to route_to('spotlight/feature_pages#update', id: '2', exhibit_id: '1')
        expect(put('/1/about/2')).to route_to('spotlight/about_pages#update', id: '2', exhibit_id: '1')
      end

      it 'routes to #destroy' do
        expect(delete('/1/feature/2')).to route_to('spotlight/feature_pages#destroy', id: '2', exhibit_id: '1')
        expect(delete('/1/about/2')).to route_to('spotlight/about_pages#destroy', id: '2', exhibit_id: '1')
      end
    end
  end
end
