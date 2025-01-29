# frozen_string_literal: true

RSpec.describe Spotlight::TranslationsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '#edit' do
    context 'when not signed in' do
      it 'is not successful' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as curator' do
      before { sign_in user }

      let(:user) { FactoryBot.create(:exhibit_curator, exhibit:) }

      it 'is successful' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to render_template(:edit)
        expect(response).to be_successful
      end

      it 'shows the breadcrumbs' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Translations')
        get :edit, params: { exhibit_id: exhibit }
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

      let(:user) { FactoryBot.create(:exhibit_curator, exhibit:) }
      let(:translation) { FactoryBot.create(:translation, exhibit:, value: 'foo') }

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

  describe '#show' do
    render_views
    before do
      sign_in user
      FactoryBot.create(:translation, exhibit:, locale: 'es', key: "#{exhibit.slug}.title", value: 'Titulo')
    end

    let(:user) { FactoryBot.create(:site_admin) }

    it 'provides a YML dump of the default language translations' do
      get :show, params: { exhibit_id: exhibit, format: 'yaml' }
      expect(response).to be_successful
      translations = YAML.safe_load(response.body).with_indifferent_access

      expect(translations).to include :en
      expect(translations[:en]).to include :blacklight, :spotlight, exhibit.slug
    end

    it 'provides a YML dump of the requested language translations' do
      get :show, params: { exhibit_id: exhibit, format: 'yaml', locale: 'es' }
      expect(response).to be_successful
      translations = YAML.safe_load(response.body).with_indifferent_access

      expect(translations).to include :es
      expect(translations[:es]).to include :blacklight, :spotlight, exhibit.slug
      expect(translations[:es][exhibit.slug]).to include title: 'Titulo', subtitle: nil
    end
  end

  describe '#import' do
    before { sign_in user }

    let(:user) { FactoryBot.create(:site_admin) }

    it 'is successful' do
      f = Tempfile.new('foo')
      begin
        f.write({ en: { exhibit.slug => { title: 'Imported title' } } }.deep_stringify_keys.to_yaml)
        f.rewind
        file = Rack::Test::UploadedFile.new(f.path, 'text/plain')
        patch :import, params: { exhibit_id: exhibit, file: }
      ensure
        f.close
        f.unlink
      end
      expect(response).to be_redirect
      assigns[:exhibit].tap do |saved|
        expect(saved.title).to eq 'Imported title'
      end
    end
  end
end
