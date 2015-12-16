require 'spec_helper'

describe Spotlight::VersionsController, type: :controller do
  routes { Spotlight::Engine.routes }

  describe 'when not logged in' do
    describe 'POST revert' do
      it 'is not allowed' do
        post :revert, id: 1
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when not authorized for the exhibit resource' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:user) { FactoryGirl.create(:exhibit_visitor) }
    let!(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    before do
      sign_in user
    end

    describe 'POST revert' do
      it 'is not allowed' do
        post :revert, id: page.versions.last
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when logged in as a curator' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    let!(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    before do
      sign_in user
    end

    describe 'POST revert' do
      it 'reverts the change' do
        page.title = 'xyz'
        page.save!

        post :revert, id: page.versions.last
        page.reload
        expect(page.title).not_to eq 'xyz'
        expect(response).to redirect_to [exhibit, page]
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to match(/Redo changes/)
      end
    end
  end
end
