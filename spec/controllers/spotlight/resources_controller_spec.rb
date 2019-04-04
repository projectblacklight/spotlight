# frozen_string_literal: true

describe Spotlight::ResourcesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when not logged in' do
    describe 'GET new' do
      it 'is not allowed' do
        get :new, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET monitor' do
      it 'is not allowed' do
        get :monitor, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'POST create' do
      it 'is not allowed' do
        post :create, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'POST reindex_all' do
      it 'is not allowed' do
        post :reindex_all, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET new' do
      it 'renders form' do
        get :new, params: { exhibit_id: exhibit }
        expect(response).to render_template 'spotlight/resources/new'
      end
    end

    describe 'GET monitor' do
      it 'succesfully renders json' do
        get :monitor, params: { exhibit_id: exhibit }
        expect(response).to be_successful
      end
    end

    describe 'POST create' do
      let(:blacklight_solr) { double }
      let(:invalid_resource) { Spotlight::Resource.new.tap { |x| x.errors.add(:url, 'is invalid') } }
      it 'create a resource' do
        expect_any_instance_of(Spotlight::Resource).to receive(:reindex_later).and_return(true)
        allow_any_instance_of(Spotlight::Resource).to receive(:blacklight_solr).and_return blacklight_solr
        post :create, params: { exhibit_id: exhibit, resource: { url: 'info:uri' } }
        expect(assigns[:resource]).to be_persisted
      end

      it 'adds errors to the flash message' do
        allow_any_instance_of(Spotlight::Resource).to receive_messages(save: false)
        allow_any_instance_of(Spotlight::Resource).to receive(:errors).and_return invalid_resource.errors
        post :create, params: { exhibit_id: exhibit, resource: { url: 'info:uri' } }
        expect(assigns[:resource]).not_to be_persisted
        expect(flash[:error]).to include 'Url is invalid'
      end
    end

    describe 'POST reindex_all' do
      it 'triggers a reindex' do
        expect_any_instance_of(Spotlight::Exhibit).to receive(:reindex_later)
        post :reindex_all, params: { exhibit_id: exhibit }
        expect(response).to redirect_to admin_exhibit_catalog_path(exhibit)
        expect(flash[:notice]).to include 'Reindexing'
      end
    end
  end
end
