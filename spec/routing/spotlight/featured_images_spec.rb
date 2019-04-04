# frozen_string_literal: true

describe 'Featured Images Controller', type: :routing do
  describe 'routing' do
    routes { Spotlight::Engine.routes }

    it 'routes to /contact_images to #create' do
      expect(post('/contact_images')).to route_to 'spotlight/featured_images#create'
    end

    it 'routes to /exhibit_thumbnails to #create' do
      expect(post('/exhibit_thumbnails')).to route_to 'spotlight/featured_images#create'
    end

    it 'routes to /mastheads to #create' do
      expect(post('/mastheads')).to route_to 'spotlight/featured_images#create'
    end

    it 'routes to /featured_images to #create' do
      expect(post('/featured_images')).to route_to 'spotlight/featured_images#create'
    end
  end
end
