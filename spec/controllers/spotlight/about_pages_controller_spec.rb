require 'spec_helper'

describe Spotlight::AboutPagesController do
  routes { Spotlight::Engine.routes }
  let(:valid_attributes) { { "title" => "MyString" } }
  describe "when not logged in" do

    describe "POST update_all" do
      let(:exhibit) { Spotlight::Exhibit.default }
      it "should not be allowed" do
        post :update_all, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    before {sign_in user }

    describe "GET show" do
      let(:page) { FactoryGirl.create(:about_page, weight: 0) }
      let(:page2) { FactoryGirl.create(:about_page, weight: 5) }
      let(:exhibit) { page.exhibit }
      describe "on the main about page" do
        it "is successful" do
          expect(controller).to receive(:add_breadcrumb).with(exhibit.title, exhibit)
          expect(controller).to receive(:add_breadcrumb).with("About", page)
          get :show, id: page
          expect(assigns(:page)).to eq page
          expect(assigns(:exhibit)).to eq Spotlight::Exhibit.default
        end
      end
      describe "on a different about page" do
        it "is successful" do
          expect(controller).to receive(:add_breadcrumb).with(exhibit.title, exhibit)
          expect(controller).to receive(:add_breadcrumb).with('About', page)
          expect(controller).to receive(:add_breadcrumb).with(page2.title, page2)
          get :show, id: page2
          expect(assigns(:page)).to eq page2
          expect(assigns(:exhibit)).to eq Spotlight::Exhibit.default
        end
      end
    end

    describe "GET index" do
      let!(:page) { FactoryGirl.create(:about_page) }
      it "is successful" do
        get :index, exhibit_id: Spotlight::Exhibit.default
        expect(assigns(:pages)).to include page
        expect(assigns(:exhibit)).to eq Spotlight::Exhibit.default
      end
    end
    describe "POST create" do
      it "redirects to the feature page index" do
        post :create, about_page: {title: "MyString"}, exhibit_id: Spotlight::Exhibit.default
        response.should redirect_to(exhibit_about_pages_path(Spotlight::AboutPage.last.exhibit))
      end
    end
    describe "PUT update" do
      let!(:page) { FactoryGirl.create(:about_page) }
      it "redirects to the about page index action" do
        put :update, id: page, exhibit_id: page.exhibit.id, about_page: valid_attributes
        response.should redirect_to(exhibit_about_pages_path(page.exhibit.id))
      end
    end
    describe "POST update_all" do
      let!(:page1) { FactoryGirl.create(:about_page) }
      let!(:page2) { FactoryGirl.create(:about_page, exhibit: page1.exhibit, published: true ) }
      let!(:page3) { FactoryGirl.create(:about_page, exhibit: page1.exhibit, published: true ) }
      before { request.env["HTTP_REFERER"] = "http://example.com" }
      it "should update whether they are on the landing page" do
        post :update_all, exhibit_id: page1.exhibit, exhibit: {about_pages_attributes: [{id: page1.id, published: true, title: "This is a new title!"}, {id: page2.id, published: false}]}
        expect(response).to redirect_to 'http://example.com'
        expect(flash[:notice]).to eq "About pages were successfully updated."
        expect(page1.reload.published).to be_true
        expect(page1.title).to eq "This is a new title!" 
        expect(page2.reload.published).to be_false
        expect(page3.reload.published).to be_true # should remain untouched since it wasn't in present[]
      end
    end

    describe "PATCH update_contacts" do
      let!(:contact1) { FactoryGirl.create(:contact, name: 'Aphra Behn', exhibit: exhibit) }
      let!(:contact2) { FactoryGirl.create(:contact, exhibit: exhibit) }
      let(:exhibit) { user.roles.first.exhibit }
      it "should update contacts" do
        patch :update_contacts, exhibit_id: exhibit, exhibit: {contacts_attributes: [
          {"show_in_sidebar"=>"1", "id"=>contact1.id},
          {"show_in_sidebar"=>"0", "id"=>contact2.id}]}
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(flash[:notice]).to eq 'Contacts were successfully updated.'
        expect(exhibit.contacts.size).to eq 2
        expect(exhibit.contacts.published.map(&:name)).to eq ['Aphra Behn']
      end
      it "should show index on failure" do
        Spotlight::Exhibit.any_instance.should_receive(:update).and_return(false)
        patch :update_contacts, exhibit_id: exhibit, exhibit: {contacts_attributes: [
          {"show_in_sidebar"=>"1", "name"=>"Justin Coyne", "email"=>"jcoyne@justincoyne.com", "title"=>"", "location"=>"US"},
          {"show_in_sidebar"=>"0", "name"=>"", "email"=>"", "title"=>"", "location"=>""},
          {"show_in_sidebar"=>"0", "name"=>"", "email"=>"", "title"=>"Librarian", "location"=>""}]}
        response.should render_template("index")
      end
    end
  end
end
