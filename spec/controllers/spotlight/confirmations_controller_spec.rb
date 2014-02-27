require 'spec_helper'

describe Spotlight::ConfirmationsController do
  routes { Spotlight::Engine.routes }
  before {
     @request.env["devise.mapping"] = Devise.mappings[:contact_email]
  }
  it "should have new" do
    get :new
    expect(response).to be_successful
  end

  describe "#show" do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:contact_email) { Spotlight::ContactEmail.create!(:email=> 'justin@example.com', exhibit: exhibit ) }
    let(:raw_token) { contact_email.instance_variable_get(:@raw_confirmation_token) }
    describe "when the token is invalid" do
      it "should give reset instructions" do
        get :show
        expect(response).to be_successful
      end
    end
    describe "when the token is valid" do
      it "should update the user" do
        get :show, confirmation_token: raw_token
        expect(contact_email.reload).to be_confirmed
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end
end
