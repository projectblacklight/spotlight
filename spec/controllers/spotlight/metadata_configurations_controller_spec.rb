require 'spec_helper'
describe Spotlight::MetadataConfigurationsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'GET show' do
      it 'denies access' do
        get :show, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
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
        expect(controller).to receive(:add_breadcrumb).with('Metadata', edit_exhibit_metadata_configuration_path(exhibit))
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe 'GET show' do
      it 'is successful' do
        get :show, exhibit_id: exhibit, format: 'json'
        expect(response).to be_successful
        expect(JSON.parse(response.body).keys).to eq exhibit.blacklight_config.index_fields.keys
      end
    end

    describe 'PATCH update' do
      it 'updates metadata fields' do
        blacklight_config = Blacklight::Configuration.new
        blacklight_config.add_index_field %w(a b c d e f)
        allow(::CatalogController).to receive_messages(blacklight_config: blacklight_config)
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          index_fields: {
            c: { enabled: true, show: true },
            d: { enabled: true, show: true },
            e: { enabled: true, list: true },
            f: { enabled: true, list: true }
          }
        }

        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_metadata_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.index_fields).to include 'c', 'd', 'e', 'f'
        end
      end
    end
  end
end
