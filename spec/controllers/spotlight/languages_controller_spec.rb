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
        expect(response).to redirect_to edit_exhibit_path(exhibit, tab: 'language')
        expect(assigns[:exhibit].languages.first.locale).to eq 'es'
        expect(flash[:notice]).to eq 'The language was created.'
      end

      it 'validates language params' do
        post :create, params: { exhibit_id: exhibit, language: { locale: nil } }
        expect(response).to redirect_to edit_exhibit_path(exhibit, tab: 'language')
        expect(flash[:alert]).to include "Language can't be blank"
      end

      it 'creates a published home page for the language' do
        expect(Spotlight::HomePage.for_locale('es')).to be_blank

        post :create, params: { exhibit_id: exhibit, language: { locale: 'es' } }
        locale_pages = Spotlight::HomePage.for_locale('es')
        expect(locale_pages.length).to eq 1
        expect(locale_pages.first.exhibit).to eq exhibit
        expect(locale_pages.first).to be_published
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
        expect(response).to redirect_to edit_exhibit_path(exhibit, tab: 'language')
        expect(assigns[:exhibit].languages.count).to eq 0
        expect(flash[:notice]).to eq 'The language was deleted.'
      end
    end
  end
end
