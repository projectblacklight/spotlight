describe 'Translation editing', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Sample', subtitle: 'SubSample') }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before do
    FactoryBot.create(:language, exhibit: exhibit, locale: 'sq')
    FactoryBot.create(:language, exhibit: exhibit, locale: 'fr')
    login_as admin
  end
  describe 'general' do
    before do
      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
    end

    it 'selects the correct language' do
      expect(page).to have_css '.nav-pills li.active', text: 'French'
    end
    it 'successfully adds translations' do
      within '.translation-edit-form #general' do
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

  describe 'Browse categories' do
    before do
      FactoryBot.create(:search, exhibit: exhibit, title: 'Browse Category 1')

      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
    end

    it 'has a title for every browse category' do
      within '#browse' do
        expect(page).to have_css('input[type="text"]', count: 2)
        expect(page).to have_field 'All Exhibit Items'
        expect(page).to have_field 'Browse Category 1'
      end
    end

    it 'only renders a description field if search has one' do
      within '#browse #browse_category_description_1' do
        expect(page).to have_css('textarea', count: 1)

        expect(page).to have_css('.help-block', text: 'All items in this exhibit.')
      end
    end

    it 'persists changes', js: true do
      click_link 'Browse categories'

      within('#browse', visible: true) do
        fill_in 'All Exhibit Items', with: "Tous les objets d'exposition"

        click_button 'Description'

        textarea = page.find('textarea')
        textarea.set('Tous les articles de cette exposition.')

        click_button 'Save changes'
      end

      expect(page).to have_css('.flash_messages', text: 'The exhibit was successfully updated.')

      expect(exhibit.searches.first.title).to eq 'All Exhibit Items'
      expect(exhibit.searches.first.long_description).to eq 'All items in this exhibit.'

      I18n.locale = :fr
      expect(exhibit.searches.first.title).to eq "Tous les objets d'exposition"
      expect(exhibit.searches.first.long_description).to eq 'Tous les articles de cette exposition.'
      I18n.locale = I18n.default_locale
    end
  end
end
