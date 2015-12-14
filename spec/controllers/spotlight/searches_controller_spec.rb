require 'spec_helper'

describe Spotlight::SearchesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'POST create' do
      it 'denies access' do
        post :create, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'GET index' do
      it 'denies access' do
        get :index, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when the user is a curator' do
    before do
      sign_in FactoryGirl.create(:exhibit_curator, exhibit: exhibit)
    end
    let(:search) { FactoryGirl.create(:search, exhibit: exhibit) }

    it 'creates a saved search' do
      request.env['HTTP_REFERER'] = '/referring_url'
      post :create, 'search' => { 'title' => 'A bunch of maps' }, 'f' => { 'genre_ssim' => ['map'] }, exhibit_id: exhibit
      expect(response).to redirect_to '/referring_url'
      expect(flash[:notice]).to eq 'The search was created.'
      expect(assigns[:search].title).to eq 'A bunch of maps'
      expect(assigns[:search].query_params).to eq('f' => { 'genre_ssim' => ['map'] })
    end

    describe 'GET index' do
      let!(:search) { FactoryGirl.create(:search, exhibit: exhibit) }
      it 'shows all the items' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_searches_path(exhibit))
        get :index, exhibit_id: search.exhibit_id
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq search.exhibit
        expect(assigns[:searches]).to include search
      end

      it 'has a JSON response with published resources' do
        search.published = true
        search.save!

        get :index, exhibit_id: exhibit, format: 'json'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.size).to eq 1
        expect(json.last).to include('id' => search.id, 'title' => search.title)
      end
    end

    describe 'GET autocomplete' do
      let(:search) do
        FactoryGirl.create(:search, exhibit: exhibit, title: 'New Mexico Maps', query_params: { q: 'New Mexico' })
      end

      let(:search_fq) do
        FactoryGirl.create(:search, exhibit: exhibit, title: 'New Mexico Maps', query_params: { f: { subject_geographic_ssim: ['Pacific Ocean'] } })
      end

      it "shows all the items returned search's query_params" do
        pending("A search defined by a query doesn't work with autocomplete correctly.")
        get :autocomplete, exhibit_id: exhibit, id: search, format: 'json'
        expect(response).to be_successful
        docs = JSON.parse(response.body)['docs']
        doc_ids = docs.map { |d| d['id'] }
        expect(docs.length).to eq 2
        expect(doc_ids).to include 'cz507zk0531'
        expect(doc_ids).to include 'rz818vx8201'
      end
      it 'searches within the items returned in the query_params' do
        get :autocomplete, exhibit_id: exhibit, id: search_fq, q: 'California', format: 'json'
        expect(response).to be_successful
        docs = JSON.parse(response.body)['docs']
        expect(docs.length).to eq 1
        expect(docs.first['id']).to eq 'sn161bw2027'
        expect(docs.first['description']).to eq 'sn161bw2027'
        expect(docs.first['title']).to match(/Pas-caart van Zuyd-Zee/)
        expect(docs.first).to have_key('thumbnail')
        expect(docs.first).to have_key('url')
      end
    end

    describe 'GET edit' do
      it 'shows edit page' do
        get :edit, id: search, exhibit_id: search.exhibit
        expect(response).to be_successful
        expect(assigns[:search]).to eq search
        expect(assigns[:exhibit]).to eq search.exhibit
      end
    end

    describe 'PATCH update' do
      it 'shows edit page' do
        patch :update, id: search, exhibit_id: search.exhibit, search: {
          title: 'Hey man',
          long_description: 'long',
          featured_image: 'http://lorempixel.com/64/64/'
        }

        expect(assigns[:search].title).to eq 'Hey man'
        expect(response).to redirect_to exhibit_searches_path(search.exhibit)
      end

      it "renders edit if there's an error" do
        expect_any_instance_of(Spotlight::Search).to receive(:update).and_return(false)
        patch :update, id: search, exhibit_id: search.exhibit, search: {
          title: 'Hey man',
          long_description: 'long',
          featured_image: 'http://lorempixel.com/64/64/'
        }

        expect(response).to be_successful
        expect(response).to render_template 'edit'
      end
    end

    describe 'DELETE destroy' do
      let!(:search) { FactoryGirl.create(:search, exhibit: exhibit) }
      it 'removes it' do
        expect do
          delete :destroy, id: search, exhibit_id: search.exhibit
        end.to change { Spotlight::Search.count }.by(-1)
        expect(response).to redirect_to exhibit_searches_path(search.exhibit)
        expect(flash[:alert]).to eq 'The search was deleted.'
      end
    end

    describe 'POST update_all' do
      let!(:search2) { FactoryGirl.create(:search, exhibit: exhibit, published: true) }
      let!(:search3) { FactoryGirl.create(:search, exhibit: exhibit, published: true) }
      before { request.env['HTTP_REFERER'] = 'http://example.com' }
      it 'updates whether they are on the landing page' do
        post :update_all, exhibit_id: exhibit, exhibit: {
          searches_attributes: [
            { id: search.id, published: true, weight: '1' },
            { id: search2.id, published: false, weight: '0' }
          ]
        }

        expect(search.reload.published).to be_truthy
        expect(search.weight).to eq 1
        expect(search2.reload.published).to be_falsey
        expect(search3.reload.published).to be_truthy # should remain untouched since it wasn't present
        expect(response).to redirect_to 'http://example.com'
        expect(flash[:notice]).to eq 'Searches were successfully updated.'
      end
    end
  end
end
