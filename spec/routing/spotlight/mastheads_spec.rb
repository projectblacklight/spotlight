describe 'Mastheads controller', type: :routing do
  describe 'routing' do
    routes { Spotlight::Engine.routes }

    it 'routes to #create' do
      expect(post('/mastheads')).to route_to 'spotlight/mastheads#create'
    end
  end
end
