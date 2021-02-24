# frozen_string_literal: true

describe Spotlight::BulkActionsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(Spotlight::ChangeVisibilityJob).to receive(:perform_later)
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'POST visibility' do
      it 'denies access' do
        post :visibility, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when the user is a curator' do
    before do
      sign_in FactoryBot.create(:exhibit_curator, exhibit: exhibit)
    end

    let(:search) { FactoryBot.create(:search, exhibit: exhibit) }
    let(:search_session) { instance_double('Blacklight::Search', query_params: { q: 'map' }) }

    it 'redirects and sets a notice' do
      allow(controller).to receive(:current_search_session).and_return(search_session)
      request.env['HTTP_REFERER'] = '/referring_url'
      post :visibility, params: { 'visibility' => 'private', 'q' => 'map', exhibit_id: exhibit }
      expect(response).to redirect_to '/referring_url'
      expect(flash[:notice]).to eq 'Visibility of 55 items is being updated.'
    end
  end
end