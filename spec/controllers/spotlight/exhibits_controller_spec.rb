require 'spec_helper'
describe Spotlight::ExhibitsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }


  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should deny access" do
      get :edit, id: exhibit 
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when not logged in" do
    describe "#edit" do
      it "should not be allowed" do
        get :edit, id: exhibit 
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#update" do
      it "should not be allowed" do
        patch :update, id: exhibit 
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:exhibit_admin) }
    before {sign_in user }
    describe "#edit" do
      it "should be successful" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Administration", exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Settings", edit_exhibit_path(exhibit))
        get :edit, id: exhibit
        expect(response).to be_successful
      end
    end


    describe "#update" do
      it "should be successful" do
        patch :update, id: exhibit, exhibit: { title: "Foo", subtitle: "Bar",
                 description: "Baz", contact_emails_attributes: {'0'=>{email: 'bess@stanford.edu'}, '1'=>{email: 'naomi@stanford.edu'}}}
        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path 
        assigns[:exhibit].tap do |saved|
          expect(saved.title).to eq 'Foo'
          expect(saved.subtitle).to eq 'Bar'
          expect(saved.description).to eq 'Baz'
          expect(saved.contact_emails.pluck(:email)).to eq ['bess@stanford.edu', 'naomi@stanford.edu']
        end
      end
    end
  end
end
