require 'spec_helper'
describe Spotlight::SearchConfigurationsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when not logged in' do
    describe 'PATCH update' do
      it 'denies access' do
        patch :update, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in' do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Configuration', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Search', edit_exhibit_search_configuration_path(exhibit))
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
      end

      it 'assigns the field metadata' do
        get :edit, exhibit_id: exhibit
        expect(assigns(:field_metadata)).to be_an_instance_of(Spotlight::FieldMetadata)
        expect(assigns(:field_metadata).repository).to eq controller.repository
        expect(assigns(:field_metadata).blacklight_config).to eq controller.blacklight_config
      end
    end

    describe 'PATCH update' do
      it 'updates facet fields' do
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          facet_fields: { 'genre_ssim' => { enabled: '1', label: 'Label' } }
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_search_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.facet_fields.keys).to eq ['genre_ssim']
        end
      end

      it 'updates sort fields' do
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          sort_fields: {
            'relevance' => { 'enabled' => '1', 'label' => 'Relevance' },
            'title' => { 'enabled' => '1', 'label' => 'Title' },
            'type' => { 'enabled' => '1', 'label' => 'Type' },
            'date' => { 'enabled' => '0', 'label' => 'Date' },
            'source' => { 'enabled' => '0', 'label' => 'Source' },
            'identifier' => { 'enabled' => '0', 'label' => 'Identifier' }
          }
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_search_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.sort_fields).to eq(
            'relevance' => { 'label' => 'Relevance', 'enabled' => true },
            'title' => { 'label' => 'Title', 'enabled' => true },
            'type' => { 'label' => 'Type', 'enabled' => true },
            'date' => { 'label' => 'Date', 'enabled' => false },
            'source' => { 'label' => 'Source', 'enabled' => false },
            'identifier' => { 'label' => 'Identifier', 'enabled' => false }
          )
        end
      end

      it 'updates search fields' do
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          search_fields: {
            'all_fields' => { 'enabled' => '1' },
            'title' => { 'enabled' => '0', 'label' => 'Title' },
            'author' => { 'enabled' => '1', 'label' => 'Primary Author' }
          }
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_search_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.search_fields).to eq(
            'all_fields' => { 'label' => 'Everything', 'enabled' => true },
            'title' => { 'label' => 'Title', 'enabled' => false },
            'author' => { 'label' => 'Primary Author', 'enabled' => true }
          )
        end
      end

      it 'updates appearance fields' do
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          document_index_view_types: { 'list' => '1', 'gallery' => '1', 'map' => '0' },
          default_per_page: '50'
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_search_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.document_index_view_types).to eq %w(list gallery)
          expect(saved.blacklight_configuration.default_per_page).to eq 50
        end
      end
    end
  end
end
