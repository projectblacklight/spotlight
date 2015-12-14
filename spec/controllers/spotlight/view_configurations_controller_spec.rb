require 'spec_helper'
describe Spotlight::ViewConfigurationsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'GET show' do
      it 'denies access' do
        get :show, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when signed in' do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET show' do
      it 'is successful' do
        get :show, exhibit_id: exhibit, format: 'json'
        expect(response).to be_successful
        available = JSON.parse(response.body)
        expect(available).to match_array %w(list gallery slideshow)
      end
    end
  end
end
