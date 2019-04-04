# frozen_string_literal: true

describe Spotlight::SitesController, type: :controller do
  routes { Spotlight::Engine.routes }

  describe 'when user does not have access' do
    before { sign_in FactoryBot.create(:exhibit_visitor) }

    describe 'GET edit' do
      it 'denies access' do
        get :edit
        expect(response).to redirect_to main_app.root_path
      end
    end
  end

  describe 'when user is an admin' do
    let(:admin) { FactoryBot.create(:site_admin) }
    before { sign_in admin }

    describe 'GET edit' do
      it 'allows access' do
        get :edit
        expect(response).to be_successful
      end
    end

    describe 'GET edit_exhibits' do
      it 'allows access' do
        get :edit_exhibits
        expect(response).to be_successful
      end
    end

    describe 'PATCH update' do
      let!(:exhibit_a) { FactoryBot.create(:exhibit) }
      let!(:exhibit_b) { FactoryBot.create(:exhibit) }

      it 'changes the exhibit order' do
        patch :update, params: {
          site: {
            exhibits_attributes: [{ id: exhibit_a.id, weight: 5 }, { id: exhibit_b.id, weight: 2 }],
            masthead_attributes: { display: 0 }
          }
        }

        expect(response).to redirect_to(exhibits_path)

        expect(Spotlight::Exhibit.ordered_by_weight.first).to eq exhibit_b
        expect(exhibit_a.reload.weight).to eq 5
      end
    end

    describe 'GET tags' do
      let!(:exhibit_a) { FactoryBot.create(:exhibit, tag_list: 'a') }

      it 'serializes the exhibit-level tags' do
        get :tags, params: { format: 'json' }
        expect(response).to be_successful
        data = JSON.parse(response.body)

        expect(data).to include 'a'
      end
    end
  end
end
