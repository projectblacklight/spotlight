require 'spec_helper'

describe Spotlight::RolesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when user does not have access' do
    before { sign_in FactoryGirl.create(:exhibit_visitor) }
    it 'does not allow index' do
      get :index, exhibit_id: exhibit
      expect(response).to redirect_to main_app.root_path
    end
  end

  describe 'when user is an admin' do
    let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    let(:role) { admin.roles.first }
    before { sign_in admin }
    it 'allows index' do
      expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
      expect(controller).to receive(:add_breadcrumb).with('Configuration', exhibit_dashboard_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with('Users', exhibit_roles_path(exhibit))
      get :index, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:roles].to_a).to eq [admin.roles.first]
    end

    describe 'PATCH update_all' do
      it 'is successful' do
        patch :update_all, exhibit_id: exhibit, 'exhibit' => {
          'roles_attributes' => {
            '0' => { 'user_key' => 'cbeer@cbeer.io', 'role' => 'curator', 'id' => role.id },
            '1' => { 'user_key' => '', 'role' => 'admin' }
          }
        }
        expect(response).to redirect_to exhibit_roles_path(exhibit)
        expect(flash[:notice]).to eq 'User has been updated.'
        expect(admin.reload.roles.first.role).to eq 'curator'
        expect(admin.reload.roles.first.user.email).to eq 'cbeer@cbeer.io'
      end

      it 'authorizes records' do
        allow(controller).to receive(:authorize!).and_raise(CanCan::AccessDenied)
        patch :update_all, exhibit_id: exhibit, 'exhibit' => {
          'roles_attributes' => {
            '0' => { 'user_key' => 'cbeer@cbeer.info', 'role' => 'curator', 'id' => role.id }
          }
        }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        expect(admin.reload.roles.first.role).to eq 'admin'
      end

      it 'destroys records' do
        patch :update_all, exhibit_id: exhibit, 'exhibit' => {
          'roles_attributes' => {
            '0' => { 'user_key' => 'cbeer@cbeer.info', 'role' => 'curator', 'id' => role.id, '_destroy' => '1' }
          }
        }

        expect(response).to redirect_to exhibit_roles_path(exhibit)
        expect(admin.reload.roles).to be_empty
        expect(flash[:notice]).to eq 'User has been removed.'
      end

      it 'handles failure' do
        allow_any_instance_of(Spotlight::Exhibit).to receive_messages(update: false)
        patch :update_all, exhibit_id: exhibit, 'exhibit' => {
          'roles_attributes' => {
            '0' => { 'user_key' => 'cbeer@cbeer.info', 'role' => 'curator', 'id' => role.id }
          }
        }
        expect(response).to be_successful
        expect(flash[:alert]).to eq 'There was a problem saving the users.'
      end
    end
  end
end
