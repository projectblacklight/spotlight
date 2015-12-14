require 'spec_helper'

describe Spotlight::ConfirmationsController, type: :controller do
  routes { Spotlight::Engine.routes }
  before do
    # rubocop:disable RSpec/InstanceVariable
    @request.env['devise.mapping'] = Devise.mappings[:contact_email]
    # rubocop:enable RSpec/InstanceVariable
  end

  describe 'GET new' do
    it 'exists' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:contact_email) { Spotlight::ContactEmail.create!(email: 'justin@example.com', exhibit: exhibit) }
    let(:raw_token) { contact_email.instance_variable_get(:@raw_confirmation_token) }
    describe 'when the token is invalid' do
      it 'gives reset instructions' do
        get :show
        expect(response).to be_successful
      end
    end
    describe 'when the token is valid' do
      it 'updates the user' do
        get :show, confirmation_token: raw_token
        expect(contact_email.reload).to be_confirmed
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end
end
