require 'spec_helper'

describe Spotlight::TagsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when not signed in' do
    describe 'GET index' do
      it 'redirects to sign inl' do
        get :index, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end
  describe 'when signed in as a curator' do
    before { sign_in FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    describe 'GET index' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Tags', exhibit_tags_path(exhibit))
        get :index, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:tags]).to eq []
        expect(assigns[:exhibit]).to eq exhibit
      end

      it 'has a json serialization' do
        get :index, exhibit_id: exhibit, format: 'json'
        expect(response).to be_successful
      end
    end

    describe 'DELETE destroy' do
      let!(:tagging) { FactoryGirl.create(:tagging, tagger: exhibit) }
      it 'is successful' do
        expect do
          delete :destroy, exhibit_id: exhibit, id: tagging.tag
        end.to change { ActsAsTaggableOn::Tagging.count }.by(-1)
        expect(response).to redirect_to exhibit_tags_path(exhibit)
      end
    end
  end
end
