require 'spec_helper'
describe Spotlight::FacetConfigurationsController, type: :controller do
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
        expect(controller).to receive(:add_breadcrumb).with('Search facets', edit_exhibit_facet_configuration_path(exhibit))
        allow(controller).to receive_message_chain(:repository, :send_and_receive).and_return({})
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe '#alternate_count' do
      before { controller.instance_variable_set(:@blacklight_configuration, exhibit.blacklight_configuration) }
      subject { controller.send(:alternate_count) }
      its(:count) { should eq 7 }
      it 'has correct numbers' do
        expect(subject['genre_ssim']).to eq 54
      end
    end

    describe '#update' do
      it 'updates facet fields' do
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          facet_fields: { 'genre_ssim' => { enabled: '1', label: 'Label' } }
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_facet_configuration_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.facet_fields.keys).to eq ['genre_ssim']
        end
      end
    end
  end
end
