require 'spec_helper'
describe Spotlight::ExhibitsController do
  routes { Spotlight::Engine.routes }
  describe "when not logged in" do
    describe "#edit" do
      it "should not be allowed" do
        expect{ get :edit }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:user_with_exhibit) }
    before {sign_in user }
    describe "#edit" do
      it "should be successful" do
        get :edit
        expect(response).to be_successful
      end
    end
  end
end
