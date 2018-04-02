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
    describe 'basic settings' do
      it 'successfully adds translations' do
        within '.translation-edit-form #general' do
          expect(page).to have_css '.help-block', text: 'Sample'
          expect(page).to have_css '.help-block', text: 'SubSample'
          fill_in 'Title', id: 'exhibit_translations_attributes_0_value', with: 'Titre français'
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
    describe 'main menu' do
      it 'successfully adds translations' do
        within '.translation-edit-form #general' do
          expect(page).to have_css '.help-block', text: 'Home'
          fill_in 'Home', with: 'Maison'
          fill_in 'Browse', with: 'parcourir ceci!'
          click_button 'Save changes'
        end
        expect(page).to have_css '.flash_messages', text: 'The exhibit was successfully updated.'
        within '.translation-main-menu-home' do
          expect(page).to have_css 'input[value="Maison"]'
          expect(page).to have_css 'span.glyphicon.glyphicon-ok'
        end
        within '.translation-main-menu-browse' do
          expect(page).to have_css 'input[value="parcourir ceci!"]'
          expect(page).to have_css 'span.glyphicon.glyphicon-ok'
        end
        within '.translation-main-menu-curated-features' do
          expect(page).to_not have_css 'span.glyphicon.glyphicon-ok'
        end
        within '.translation-main-menu-about' do
          expect(page).to_not have_css 'span.glyphicon.glyphicon-ok'
        end
        I18n.locale = :fr
        expect(exhibit.main_navigations.browse.label).to eq 'parcourir ceci!'
        expect(I18n.t(:'spotlight.curation.nav.home')).to eq 'Maison'
        I18n.locale = I18n.default_locale
      end
    end
  end

  describe 'Search field labels' do
    before { visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr') }

    describe 'field-based search fields' do
      it 'has a text input for each enabled search field' do
        within '#search_fields .translation-field-based-search-fields' do
          expect(page).to have_css('input[type="text"]', count: 3)
        end
      end

      it 'allows users to translate field-based search fields', js: true do
        click_link 'Search field labels'

        within('#search_fields', visible: true) do
          fill_in 'Everything', with: 'Tout'
          click_button 'Save changes'
        end

        visit spotlight.exhibit_path(exhibit, locale: 'fr')

        expect(page).to have_css('select#search_field option', text: 'Tout')
      end
    end

    describe 'facet fields' do
      it 'has a text input for each facet field' do
        within '#search_fields .translation-facet-fields' do
          expect(page).to have_css('input[type="text"]', count: 7)
        end
      end

      it 'allows users to translate facet fields', js: true do
        click_link 'Search field labels'

        within('#search_fields', visible: true) do
          fill_in 'Geographic', with: 'Géographique'
          click_button 'Save changes'
        end

        visit spotlight.search_exhibit_catalog_path(exhibit, q: '*', locale: 'fr')

        expect(page).to have_css('h3.facet-field-heading', text: 'Géographique')
      end
    end

    describe 'sort fields' do
      it 'has a text input for each sort field' do
        within '#search_fields .translation-sort-fields' do
          expect(page).to have_css('input[type="text"]', count: 6)
        end
      end

      it 'allows users to translation sort fields', js: true do
        click_link 'Search field labels'

        within('#search_fields', visible: true) do
          fill_in 'Relevance', with: 'French Relevance'
          click_button 'Save changes'
        end

        visit spotlight.search_exhibit_catalog_path(exhibit, q: '*', locale: 'fr')

        expect(page).to have_css('.dropdown-toggle', text: 'Trier par French Relevance', visible: true)
      end
    end
  end

  describe 'Browse categories' do
    before do
      FactoryBot.create(:search, exhibit: exhibit, title: 'Browse Category 1')

      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
    end

    it 'has a title and description for every browse category' do
      within '#browse' do
        expect(page).to have_css('input[type="text"]', count: 2)
        expect(page).to have_css('textarea', count: 2)

        expect(page).to have_field 'All Exhibit Items'
        expect(page).to have_field 'Browse Category 1'
        expect(page).to have_css('.help-block', text: 'All items in this exhibit.')
      end
    end

    it 'persists changes', js: true do
      click_link 'Browse categories'

      within('#browse', visible: true) do
        fill_in 'All Exhibit Items', with: "Tous les objets d'exposition"

        first('.tanslation-description-toggle').click

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

  describe 'translation progress counter', js: true do
    before do
      FactoryBot.create(:translation, exhibit: exhibit, locale: 'fr', key: "#{exhibit.slug}.title", value: 'Titre')
    end
    it 'counts existing and total available translations' do
      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
      expect(page).to have_link('General 1/7')
      expect(page).to have_link('Search field labels 0/16')
      expect(page).to have_link('Browse categories 0/2')
    end
  end
end
