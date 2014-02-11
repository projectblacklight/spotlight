require 'spec_helper'
describe Spotlight::CustomFieldsController do
  routes { Spotlight::Engine.routes }

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    before {sign_in user }

    describe "GET new" do
      it "assigns a new custom field" do
        get :new, exhibit_id: Spotlight::Exhibit.default
        expect(assigns(:custom_field)).to be_a_new(Spotlight::CustomField)
      end
    end

    describe "GET edit" do
      let(:field) { FactoryGirl.create(:custom_field) }
      it "assigns the requested custom_field" do
        get :edit, exhibit_id: field.exhibit.id, id: field
        expect(assigns(:custom_field)).to eq field
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Page" do
          expect {
            post :create, custom_field: {configuration: { label: "MyString"}} , exhibit_id: Spotlight::Exhibit.default
          }.to change(Spotlight::CustomField, :count).by(1)
        end

        it "redirects to the exhibit metadata page" do
          post :create, custom_field: {configuration: { label: "MyString"}} , exhibit_id: Spotlight::Exhibit.default
          response.should redirect_to(exhibit_edit_metadata_path(Spotlight::Exhibit.default))
        end
      end

      describe "with invalid params" do
        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Spotlight::CustomField.any_instance.stub(:save).and_return(false)
          post :create, custom_field: {configuration: { label: "MyString"}} , exhibit_id: Spotlight::Exhibit.default
          expect(assigns(:custom_field)).to be_a_new(Spotlight::CustomField)
          response.should render_template("new")
        end
      end
    end
  end
end
