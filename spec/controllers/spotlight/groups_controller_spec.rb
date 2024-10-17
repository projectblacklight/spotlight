# frozen_string_literal: true

describe Spotlight::GroupsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:group) { FactoryBot.create(:group, exhibit:) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET index' do
      it 'returns authorized groups (none)' do
        get :index, params: { exhibit_id: exhibit }, format: :json
        expect(response).to be_successful
        expect(response.parsed_body.length).to eq 0
      end
    end

    describe 'POST create' do
      it 'denies access' do
        post :create, params: { exhibit_id: exhibit, group: { title: 'Hello' } }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'PUT update' do
      it 'denies access' do
        patch :update, params: { exhibit_id: exhibit, id: group.id }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when the user is a curator' do
    before do
      sign_in FactoryBot.create(:exhibit_curator, exhibit:)
    end

    describe 'GET index' do
      it 'returns json response of groups' do
        get :index, params: { exhibit_id: exhibit }, format: :json
        expect(response.parsed_body.length).to eq 1
      end
    end

    describe 'POST create' do
      it 'creates a saved search' do
        post :create, params: { exhibit_id: exhibit, group: { title: 'Hello' } }
        expect(response).to redirect_to spotlight.exhibit_searches_path(exhibit, anchor: 'browse-groups')
        expect(flash[:notice]).to eq 'The browse group was created.'
      end
    end

    describe 'PATCH update' do
      it 'shows edit page' do
        patch :update, params: {
          id: group.id,
          exhibit_id: group.exhibit,
          group: {
            title: 'Hello world'
          }
        }

        expect(group.reload.title).to eq 'Hello world'
        expect(response).to redirect_to exhibit_searches_path(exhibit, anchor: 'browse-groups')
      end
    end

    describe 'PATCH update_all' do
      let!(:group2) { FactoryBot.create(:group, exhibit:, published: true) }
      let!(:group3) { FactoryBot.create(:group, exhibit:, published: true) }

      it 'shows edit page' do
        patch :update_all, params: {
          exhibit_id: group.exhibit,
          exhibit: {
            groups_attributes: [
              { id: group.id, published: true, weight: '1' },
              { id: group2.id, published: false, weight: '0' }
            ]
          }
        }

        expect(group.reload.weight).to eq 1
        expect(group2.reload.published).to be false
        expect(response).to redirect_to exhibit_searches_path(exhibit, anchor: 'browse-groups')
      end
    end

    describe 'DELETE delete' do
      it 'removes the group' do
        group
        expect do
          delete :destroy, params: { id: group.id, exhibit_id: group.exhibit }
        end.to change(Spotlight::Group, :count).by(-1)
      end
    end
  end
end
