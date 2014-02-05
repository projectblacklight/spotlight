require 'spec_helper'

describe Spotlight::AboutPagesController do
  routes { Spotlight::Engine.routes }
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

    describe "GET index" do
      let!(:page) { FactoryGirl.create(:about_page) }
      it "is successful" do
        get :index, exhibit_id: Spotlight::Exhibit.default
        expect(assigns(:pages)).to include page
        expect(assigns(:exhibit)).to eq Spotlight::Exhibit.default
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
  end
end
