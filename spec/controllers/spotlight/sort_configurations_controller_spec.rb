require 'spec_helper'
describe Spotlight::SortConfigurationsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it 'denies access' do
      get :edit, exhibit_id: exhibit
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe 'when not logged in' do
    describe '#update' do
      it 'denies access' do
        patch :update, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe '#edit' do
      it 'denies access' do
        get :edit, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in' do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    before { sign_in user }

    describe '#edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Sort fields', edit_exhibit_sort_configuration_path(exhibit))
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe '#update' do
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
        expect(response).to redirect_to edit_exhibit_sort_configuration_path(exhibit)
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
    end
  end
end
