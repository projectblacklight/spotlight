# frozen_string_literal: true

describe Spotlight::AttachmentsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  describe 'when not logged in' do
    describe 'GET edit' do
      it 'is successful' do
        post :create, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'POST create' do
      it 'is successful' do
        post :create, params: { exhibit_id: exhibit, attachment: { name: 'xyz' } }
        expect(response).to be_successful
      end
    end
  end
end
