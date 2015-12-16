require 'spec_helper'

describe Spotlight::ContactsController, type: :controller do
  routes { Spotlight::Engine.routes }
  describe 'when not logged in' do
    describe 'GET edit' do
      let(:contact) { FactoryGirl.create(:contact) }
      it 'is successful' do
        get :edit, id: contact, exhibit_id: contact.exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:contact) { FactoryGirl.create(:contact, exhibit: exhibit, name: 'Andrew Carnegie') }
    before { sign_in user }

    describe 'GET edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(contact.name, edit_exhibit_contact_path(exhibit, contact))
        get :edit, id: contact, exhibit_id: contact.exhibit
        expect(response).to be_successful
      end
    end
    describe 'PATCH update' do
      it 'is successful' do
        patch :update, id: contact, contact: { name: 'Chester' }, exhibit_id: contact.exhibit
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(contact.reload.name).to eq 'Chester'
      end
      it 'fails by rendering edit' do
        expect_any_instance_of(Spotlight::Contact).to receive(:update).and_return(false)
        patch :update, id: contact, contact: { name: 'Chester' }, exhibit_id: contact.exhibit
        expect(response).to render_template 'edit'
      end
    end
    describe 'DELETE destroy' do
      it 'is successful' do
        contact # force contact to be created
        expect do
          delete :destroy, id: contact, exhibit_id: contact.exhibit
        end.to change { Spotlight::Contact.count }.by(-1)
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
      end
    end
    describe 'GET new' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Add contact', new_exhibit_contact_path(exhibit))
        get :new, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end
    describe 'POST create' do
      it 'fails by rendering new' do
        expect_any_instance_of(Spotlight::Contact).to receive(:update).and_return(false)
        post :create, exhibit_id: exhibit, contact: { name: 'Chester' }
        expect(response).to render_template 'new'
      end
      it 'is successful' do
        expect do
          post :create, exhibit_id: exhibit, contact: { name: 'Chester' }
        end.to change { Spotlight::Contact.count }.by(1)
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(Spotlight::Contact.last.show_in_sidebar).to be_truthy
      end
    end
  end
end
