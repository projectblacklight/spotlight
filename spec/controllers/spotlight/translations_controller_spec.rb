describe Spotlight::TranslationsController do
  routes { Spotlight::Engine.routes }

  describe '#edit' do
    let(:exhibit) { FactoryBot.create(:exhibit) }

    context 'when not signed in' do
      it 'is not successful' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as curator' do
      before { sign_in user }
      let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
      it 'is successful' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to render_template(:edit)
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:exhibit) { FactoryBot.create(:exhibit) }

    context 'when not signed in' do
      it 'is not successful' do
        patch :update, params: { exhibit_id: exhibit, exhibit: { translations_attributes: { 0 => { id: 0, key: 'test' } } } }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as curator' do
      before { sign_in user }
      let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
      let(:translation) { FactoryBot.create(:translation, exhibit: exhibit, value: 'foo') }
      it 'updates successfully' do
        patch :update, params: {
          exhibit_id: exhibit,
          exhibit: { translations_attributes: { 0 => { id: translation, value: 'bar' } } },
          language: 'fr'
        }
        expect(response).to redirect_to edit_exhibit_translations_path(exhibit, language: 'fr')
        translation.reload
        expect(translation.value).to eq 'bar'
      end

      context 'when emptying translation values' do
        before { translation } # ensure the translation is loaded

        it 'deletes those translations' do
          expect do
            patch :update, params: {
              exhibit_id: exhibit,
              exhibit: {
                translations_attributes: { 0 => { id: translation, value: '' } }
              },
              language: 'fr'
            }
          end.to change(Translation, :count).by(-1)
        end
      end
    end
  end
end
