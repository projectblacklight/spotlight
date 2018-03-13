describe 'Translation editing', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Sample', subtitle: 'SubSample') }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before do
    FactoryBot.create(:language, exhibit: exhibit, locale: 'sq')
    FactoryBot.create(:language, exhibit: exhibit, locale: 'fr')
    login_as admin
    visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
  end
  describe 'general' do
    it 'selects the correct language' do
      expect(page).to have_css '.nav-pills li.active', text: 'French'
    end
    it 'successfully adds translations' do
      within '.translation-edit-form' do
        expect(page).to have_css '.help-block', text: 'Sample'
        expect(page).to have_css '.help-block', text: 'SubSample'
        fill_in 'Title', with: 'Titre français'
        fill_in 'Subtitle', with: 'Sous-titre français'
        click_button 'Save changes'
      end
      expect(page).to have_css '.flash_messages', text: 'The exhibit was successfully updated.'
      within '.translation-basic-settings-title' do
        expect(page).to have_css 'input[value="Titre français"]'
        expect(page).to have_css 'span.glyphicon.glyphicon-ok'
      end
      within '.translation-basic-settings-subtitle' do
        expect(page).to have_css 'input[value="Sous-titre français"]'
        expect(page).to have_css 'span.glyphicon.glyphicon-ok'
      end
      within '.translation-basic-settings-description' do
        expect(page).to_not have_css 'span.glyphicon.glyphicon-ok'
      end
    end
  end
end
