# frozen_string_literal: true

describe Spotlight::BulkUpdatesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'POST download_template' do
      it 'denies access' do
        post :download_template, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when the user is a curator' do
    before do
      sign_in FactoryBot.create(:exhibit_curator, exhibit: exhibit)
    end

    describe 'GET edit' do
      it 'is allowed' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to be_successful
      end
    end

    describe 'POST download_template' do
      it 'downloads a CSV template' do
        post :download_template, params: {
          exhibit_id: exhibit,
          reference_fields: { item_id: 1, item_title: 1 },
          updatable_fields: { tags: 0, visibility: 1 }
        }

        content = CSV.parse(response.body)
        expect(content.length).to eq 56
        expect(content[0]).to eq ['Item ID', 'Item Title', 'Visibility']
      end
    end
  end
end
