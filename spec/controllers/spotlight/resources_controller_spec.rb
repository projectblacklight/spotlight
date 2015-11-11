require 'spec_helper'

describe Spotlight::ResourcesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when not logged in' do
    describe 'GET new' do
      it 'does not be allowed' do
        get :new, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'POST create' do
      it 'does not be allowed' do
        post :create, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'POST reindex_all' do
      it 'does not be allowed' do
        post :reindex_all, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET new' do
      it 'renders form' do
        get :new, exhibit_id: exhibit
        expect(response).to render_template 'spotlight/resources/new'
      end

      it 'populates the resource with parameters from the url' do
        get :new, exhibit_id: exhibit, resource: { url: 'info:uri' }
        expect(assigns[:resource].url).to eq 'info:uri'
      end

      describe 'Within a popup' do
        it 'renders with the simplified popup layout' do
          get :new, exhibit_id: exhibit, popup: true
          expect(response).to render_template 'layouts/spotlight/popup'
        end
      end
    end

    describe 'POST create' do
      let(:blacklight_solr) { double }
      it 'create a resource' do
        expect_any_instance_of(Spotlight::Resource).to receive(:reindex)
        allow_any_instance_of(Spotlight::Resource).to receive(:blacklight_solr).and_return blacklight_solr
        post :create, exhibit_id: exhibit, resource: { url: 'info:uri' }
        expect(assigns[:resource]).to be_persisted
      end
    end

    describe 'POST reindex_all' do
      it 'triggers a reindex' do
        expect_any_instance_of(Spotlight::Exhibit).to receive(:reindex_later)
        post :reindex_all, exhibit_id: exhibit
        expect(response).to redirect_to admin_exhibit_catalog_index_path(exhibit)
        expect(flash[:notice]).to include 'Reindexing'
      end
    end
  end
end
