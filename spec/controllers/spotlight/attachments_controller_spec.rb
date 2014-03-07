require 'spec_helper'

describe Spotlight::AttachmentsController do
  routes { Spotlight::Engine.routes }
  describe "when not logged in" do
    describe "GET edit" do
      it "should be successful" do
        post :create, exhibit_id: Spotlight::ExhibitFactory.default.id
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    let(:exhibit) { user.roles.first.exhibit }
    before {sign_in user }

    describe "POST create" do
      it "should be successful" do
        post :create, exhibit_id: Spotlight::ExhibitFactory.default.id, attachment: { name: "xyz" }
        expect(response).to be_successful
      end
    end
  end
end
