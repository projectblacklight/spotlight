# frozen_string_literal: true

describe Spotlight::ContactsController, type: :controller do
  routes { Spotlight::Engine.routes }
  describe 'when not logged in' do
    describe 'GET edit' do
      let(:contact) { FactoryBot.create(:contact) }
      it 'is successful' do
        get :edit, params: { id: contact, exhibit_id: contact.exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:contact) { FactoryBot.create(:contact, exhibit: exhibit, name: 'Andrew Carnegie') }
    before { sign_in user }

    describe 'GET edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(contact.name, edit_exhibit_contact_path(exhibit, contact))
        get :edit, params: { id: contact, exhibit_id: contact.exhibit }
        expect(response).to be_successful
      end
    end

    describe 'PATCH update' do
      it 'is successful' do
        patch :update, params: { id: contact, contact: { name: 'Chester' }, exhibit_id: contact.exhibit }
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(contact.reload.name).to eq 'Chester'
      end

      it 'allows thumbnails to be updated' do
        contact = FactoryBot.create(:contact, exhibit: exhibit, name: 'Andrew Carnegie')
        patch :update, params: {
          id: contact,
          contact: {
            avatar_attributes: {
              iiif_tilesource: 'https://example.com/iiif',
              iiif_region: '0,0,200,200'
            }
          },
          exhibit_id: contact.exhibit
        }

        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(contact.reload.avatar.iiif_url).to eq 'https://example.com/iiif/0,0,200,200/70,70/0/default.jpg'
      end

      it 'fails by rendering edit' do
        expect_any_instance_of(Spotlight::Contact).to receive(:update).and_return(false)
        patch :update, params: { id: contact, contact: { name: 'Chester' }, exhibit_id: contact.exhibit }
        expect(response).to render_template 'edit'
      end
    end

    describe 'DELETE destroy' do
      it 'is successful' do
        contact # force contact to be created
        expect do
          delete :destroy, params: { id: contact, exhibit_id: contact.exhibit }
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
        get :new, params: { exhibit_id: exhibit }
        expect(response).to be_successful
      end
    end

    describe 'POST create' do
      it 'fails by rendering new' do
        expect_any_instance_of(Spotlight::Contact).to receive(:update).and_return(false)
        post :create, params: { exhibit_id: exhibit, contact: { name: 'Chester' } }
        expect(response).to render_template 'new'
      end
      it 'is successful' do
        expect do
          post :create, params: { exhibit_id: exhibit, contact: { name: 'Chester', avatar_attributes: { iiif_tilesource: 'someurl' } } }
        end.to change { Spotlight::Contact.count }.by(1)
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(Spotlight::Contact.last.show_in_sidebar).to be_truthy
        expect(Spotlight::Contact.last.avatar.iiif_url).to be_present
      end
    end
  end
end
