require 'spec_helper'

describe Spotlight::AdminUsersController, type: :controller do
  routes { Spotlight::Engine.routes }

  before { sign_in(user) }
  context 'by a non-admin' do
    let(:user) { FactoryGirl.create(:exhibit_visitor) }
    it 'redirects with an error message' do
      get :index
      expect(response).to redirect_to '/'
      expect(flash[:alert]).to eq 'You are not authorized to access this page.'
    end
  end

  context 'by an admin user' do
    before { request.env['HTTP_REFERER'] = 'http://example.com' }
    let(:user) { FactoryGirl.create(:site_admin) }
    describe 'GET index' do
      it 'is successful' do
        get :index
        expect(response).to be_success
      end
    end

    describe 'DELETE destroy' do
      before do
        post :invite, user: 'user@example.com', role: 'admin'
      end
      it 'removes the site admin role from the given user' do
        last_user = Spotlight::Site.instance.roles.last.user
        expect(last_user.email).to eq 'user@example.com'

        delete :destroy, id: last_user.id
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq 'User removed from site adminstrator role'
        expect(Spotlight::Site.instance.roles.last.user.id).not_to eq last_user.id
      end
    end

    describe 'GET exists' do
      it 'requires a user parameter' do
        expect do
          get :exists
        end.to raise_error(ActionController::ParameterMissing)
      end

      it 'returns a successful status when the requested user exists' do
        user = FactoryGirl.create(:exhibit_curator)
        get :exists, user: user.email
        expect(response).to be_success
      end

      it 'returns an unsuccessful status when the user does not exist' do
        get :exists, user: 'user@example.com'
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end
    end

    describe 'GET invite' do
      it 'invites the selected user to be an admin' do
        expect do
          post :invite, user: 'user@example.com', role: 'admin'
        end.to change { Spotlight::Engine.user_class.count }.by(1)
        expect(Spotlight::Engine.user_class.last.roles.length).to eq 1
        expect(Spotlight::Engine.user_class.last.roles.first.resource).to eq Spotlight::Site.instance
      end

      it 'redirects back with a flash notice upon success' do
        post :invite, user: 'user@example.com', role: 'admin'
        expect(flash[:notice]).to eq 'User has been invited.'
        expect(response).to redirect_to(:back)
      end

      it 'redirects back with flash error upon failure' do
        post :invite, user: 'user@example.com', role: 'not-a-real-role'
        expect(flash[:alert]).to eq 'There was a problem saving the user(s).'
        expect(response).to redirect_to(:back)
      end
    end
  end
end
