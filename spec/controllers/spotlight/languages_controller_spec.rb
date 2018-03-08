describe Spotlight::LanguagesController do
  routes { Spotlight::Engine.routes }

  describe '#create' do
    let(:exhibit) { FactoryBot.create(:exhibit) }

    context 'when not signed in' do
      it 'is not successful' do
        post :create, params: { exhibit_id: exhibit, language: { locale: 'es' } }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as a site admin' do
      before { sign_in user }
      let(:user) { FactoryBot.create(:site_admin) }

      it 'is successful' do
        post :create, params: { exhibit_id: exhibit, language: { locale: 'es' } }
        expect(response).to redirect_to edit_exhibit_path(exhibit, anchor: 'language')
        expect(assigns[:exhibit].languages.first.locale).to eq 'es'
        expect(flash[:notice]).to eq 'The language was created.'
      end

      it 'validates language params' do
        post :create, params: { exhibit_id: exhibit, language: { locale: nil } }
        expect(response).to redirect_to edit_exhibit_path(exhibit, anchor: 'language')
        expect(flash[:alert]).to include "Language can't be blank"
      end
    end
  end

  describe '#destroy' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:language) { FactoryBot.create(:language, exhibit: exhibit) }

    context 'when not signed in' do
      it 'is not successful' do
        delete :destroy, params: { exhibit_id: exhibit, id: language }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as a site admin' do
      before { sign_in user }
      let(:user) { FactoryBot.create(:site_admin) }

      it 'is successful' do
        delete :destroy, params: { exhibit_id: exhibit, id: language }
        expect(response).to redirect_to edit_exhibit_path(exhibit, anchor: 'language')
        expect(assigns[:exhibit].languages.count).to eq 0
        expect(flash[:notice]).to eq 'The language was deleted.'
      end
    end
  end
end
