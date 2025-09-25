# frozen_string_literal: true

RSpec.describe Spotlight::AdminUsersController, type: :controller do
  routes { Spotlight::Engine.routes }

  before { sign_in(user) }

  context 'by a non-admin' do
    let(:user) { FactoryBot.create(:exhibit_visitor) }

    it 'redirects with an error message' do
      get :index
      expect(response).to redirect_to '/'
      expect(flash[:alert]).to eq 'You are not authorized to access this page.'
    end
  end

  context 'by an admin user' do
    before { request.env['HTTP_REFERER'] = 'http://example.com' }

    let(:user) { FactoryBot.create(:site_admin) }

    describe 'GET index' do
      it 'is successful' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'DELETE destroy' do
      let(:user) { FactoryBot.create(:user) }
      let!(:admin_role) { FactoryBot.create(:role, role: 'admin', user:, resource: Spotlight::Site.instance) }

      it 'removes the site admin role from the given user' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq 'User removed from site adminstrator role'
        expect(Spotlight::Site.instance.roles.where(user_id: user.id)).to be_none
      end
    end

    describe 'DELETE remove_exhibit_roles' do
      let(:exhibit_admin) { FactoryBot.create(:exhibit_admin) }

      it 'removes all exhibit roles from the given user' do
        delete :remove_exhibit_roles, params: { id: exhibit_admin.id }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq 'Removed all exhibit roles for user'
        expect(exhibit_admin.roles.where(resource_type: 'Spotlight::Exhibit')).to be_none
      end
    end

    describe 'PATCH update' do
      let(:non_admin) { FactoryBot.create(:exhibit_visitor) }

      it 'adds the site admin role to the given user' do
        patch :update, params: { id: non_admin.id }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq 'Added user as an adminstrator'
        expect(non_admin.roles.map(&:role)).to eq ['admin']
      end
    end
  end
end
