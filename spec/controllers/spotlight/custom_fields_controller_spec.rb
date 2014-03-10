require 'spec_helper'
describe Spotlight::CustomFieldsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before {sign_in user }

    describe "GET new" do
      it "assigns a new custom field" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Curation", exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Metadata", exhibit_edit_metadata_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Add new field", new_exhibit_custom_field_path(exhibit))
        get :new, exhibit_id: exhibit
        expect(assigns(:custom_field)).to be_a_new(Spotlight::CustomField)
      end
    end

    describe "GET edit" do
      let(:field) { FactoryGirl.create(:custom_field, exhibit: exhibit) }
      it "assigns the requested custom_field" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Curation", exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Metadata", exhibit_edit_metadata_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(field.label, edit_exhibit_custom_field_path(exhibit, field))
        get :edit, exhibit_id: exhibit, id: field
        expect(assigns(:custom_field)).to eq field
        expect(assigns(:exhibit)).to eq exhibit
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Page" do
          expect {
            post :create, custom_field: {label: "MyString"} , exhibit_id: exhibit 
          }.to change(Spotlight::CustomField, :count).by(1)
        end

        it "redirects to the exhibit metadata page" do
          post :create, custom_field: {label: "MyString"} , exhibit_id: exhibit 
          response.should redirect_to(exhibit_edit_metadata_path(exhibit))
        end
      end

      describe "with invalid params" do
        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Spotlight::CustomField.any_instance.stub(:save).and_return(false)
          post :create, custom_field: {label: "MyString"} , exhibit_id: exhibit
          expect(assigns(:custom_field)).to be_a_new(Spotlight::CustomField)
          response.should render_template("new")
        end
      end
    end
  end
end
