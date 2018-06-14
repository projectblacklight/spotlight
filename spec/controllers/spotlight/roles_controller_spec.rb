describe Spotlight::RolesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when user does not have access' do
    before { sign_in FactoryBot.create(:exhibit_visitor) }

    describe 'GET index' do
      it 'denies access' do
        get :index, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
      end
    end
  end

  describe 'when user is an admin' do
    let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
    let(:user) { FactoryBot.create(:user) }
    let(:role) { admin.roles.first }
    before { sign_in admin }

    it 'allows index' do
      expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
      expect(controller).to receive(:add_breadcrumb).with('Configuration', exhibit_dashboard_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with('Users', exhibit_roles_path(exhibit))
      get :index, params: { exhibit_id: exhibit }
      expect(response).to be_successful
      expect(assigns[:roles].to_a).to eq [admin.roles.first]
    end

    describe 'PATCH update_all' do
      it 'creates new roles' do
        patch :update_all, params: {
          exhibit_id: exhibit,
          'exhibit' => {
            'roles_attributes' => {
              '0' => { 'role' => 'curator', 'user_key' => user.email }
            }
          }
        }

        expect(exhibit.roles.last.role).to eq 'curator'
        expect(exhibit.roles.last.user.email).to eq user.email
        expect(flash[:notice]).to eq 'User has been updated.'
      end

      it 'invites new users' do
        expect do
          patch :update_all, params: {
            exhibit_id: exhibit,
            'exhibit' => {
              'roles_attributes' => {
                '0' => { 'role' => 'curator', 'user_key' => 'something@example.com' }
              }
            }
          }
        end.to change { Devise::Mailer.deliveries.count }.by(1)

        expect(exhibit.roles.last.user.email).to eq 'something@example.com'
        expect(exhibit.roles.last.user.invitation_sent_at).to be_present
      end

      it 'updates roles' do
        patch :update_all, params: {
          exhibit_id: exhibit,
          'exhibit' => {
            'roles_attributes' => {
              '0' => { 'role' => 'curator', 'id' => role.id }
            }
          }
        }
        expect(response).to redirect_to exhibit_roles_path(exhibit)
        expect(flash[:notice]).to eq 'User has been updated.'

        admin.reload

        expect(admin.roles.first.role).to eq 'curator'
      end

      it 'ignores empty roles' do
        expect do
          patch :update_all, params: {
            exhibit_id: exhibit,
            'exhibit' => {
              'roles_attributes' => {
                '0' => { 'user_key' => '', 'role' => '' }
              }
            }
          }
        end.not_to change { exhibit.roles.length }
      end

      it 'authorizes records' do
        allow(controller).to receive(:authorize!).and_raise(CanCan::AccessDenied)
        patch :update_all, params: {
          exhibit_id: exhibit,
          'exhibit' => {
            'roles_attributes' => {
              '0' => { 'role' => 'curator', 'id' => role.id }
            }
          }
        }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        expect(admin.reload.roles.first.role).to eq 'admin'
      end

      it 'destroys records' do
        patch :update_all, params: {
          exhibit_id: exhibit,
          'exhibit' => {
            'roles_attributes' => {
              '0' => { 'role' => 'curator', 'id' => role.id, '_destroy' => '1' }
            }
          }
        }

        expect(response).to redirect_to exhibit_roles_path(exhibit)
        expect(admin.reload.roles).to be_empty
        expect(flash[:notice]).to eq 'User has been removed.'
      end

      it 'handles failure' do
        allow_any_instance_of(Spotlight::Exhibit).to receive_messages(update: false)
        patch :update_all, params: {
          exhibit_id: exhibit,
          'exhibit' => {
            'roles_attributes' => {
              '0' => { 'role' => 'curator', 'id' => role.id }
            }
          }
        }
        expect(response).to be_successful
        expect(flash[:alert]).to eq 'There was a problem saving the user.'
      end
    end
  end
end
