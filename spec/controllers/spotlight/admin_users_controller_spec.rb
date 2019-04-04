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
      let!(:admin_role) { FactoryBot.create(:role, role: 'admin', user: user, resource: Spotlight::Site.instance) }
      it 'removes the site admin role from the given user' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq 'User removed from site adminstrator role'
        expect(Spotlight::Site.instance.roles.where(user_id: user.id)).to be_none
      end
    end
  end
end
