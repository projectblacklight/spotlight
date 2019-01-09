describe Spotlight::TagsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    exhibit.tag(SolrDocument.new(id: 'x').sidecar(exhibit), with: 'paris, normandy', on: :tags)
  end

  describe 'when not signed in' do
    describe 'GET index' do
      it 'redirects to sign inl' do
        get :index, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    before { sign_in FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

    describe 'GET index' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Tags', exhibit_tags_path(exhibit))
        get :index, params: { exhibit_id: exhibit }
        expect(response).to be_successful
        expect(assigns[:tags].length).to eq 2
        expect(assigns[:tags].map(&:name)).to match_array %w[paris normandy]
        expect(assigns[:exhibit]).to eq exhibit
      end

      it 'has a json serialization' do
        get :index, params: { exhibit_id: exhibit, format: 'json' }
        expect(response).to be_successful
      end
    end

    describe 'DELETE destroy' do
      let!(:tagging) { FactoryBot.create(:tagging, tagger: exhibit, taggable: exhibit) }
      it 'is successful' do
        expect do
          delete :destroy, params: { exhibit_id: exhibit, id: tagging.tag }
        end.to change { ActsAsTaggableOn::Tagging.count }.by(-1)
        expect(response).to redirect_to exhibit_tags_path(exhibit)
      end
    end
  end
end
