require 'spec_helper'
describe Spotlight::AppearancesController, type: :controller do
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
      it 'is not allowed' do
        patch :update, exhibit_id: exhibit
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
        expect(controller).to receive(:add_breadcrumb).with('Appearance', edit_exhibit_appearance_path(exhibit))
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:exhibit]).to be_kind_of Spotlight::Exhibit
      end
    end

    describe 'PATCH update' do
      it 'updates the navigation' do
        first_nav = exhibit.main_navigations.first
        last_nav = exhibit.main_navigations.last
        patch :update, exhibit_id: exhibit, exhibit: {
          main_navigations_attributes: [
            { id: first_nav.id, label: 'Some Label', weight: 500 },
            { id: last_nav.id, display: false }
          ]
        }
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_appearance_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.main_navigations.find(first_nav.id).label).to eq 'Some Label'
          expect(saved.main_navigations.find(first_nav.id).weight).to eq 500
          expect(saved.main_navigations.find(last_nav.id)).not_to be_displayable
        end
      end
    end
  end
end
