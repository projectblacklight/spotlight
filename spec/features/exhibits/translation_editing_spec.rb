# frozen_string_literal: true

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
      it 'adds translations to exhibit navbar' do
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

      before do
        exhibit.searches.first.update(published: true)
        within '.translation-edit-form #general' do
          fill_in 'Home', with: 'Maison'
          fill_in 'Browse', with: 'parcourir ceci!'
          click_button 'Save changes'
        end
      end
      it 'adds translations to user-facing breadcrumbs' do
        expect(page).to have_css '.flash_messages', text: 'The exhibit was successfully updated.'
        visit spotlight.exhibit_browse_index_path(exhibit, locale: 'fr')
        expect(page).to have_breadcrumbs 'Maison', 'parcourir ceci!'
      end

      it 'does not translate admin breadcrumbs' do
        expect(page).to have_css '.flash_messages', text: 'The exhibit was successfully updated.'
        visit spotlight.exhibit_searches_path(exhibit, locale: 'fr')
        expect(page).to have_breadcrumbs 'Home', 'Curation', 'Browse'
      end
    end

    describe 'breadcrumbs' do
      describe 'browse categories' do
        before do
          exhibit.searches.first.update(published: true)
          within '.translation-edit-form #general' do
            fill_in 'Home', with: 'Maison'
            fill_in 'Browse', with: 'parcourir ceci!'
            click_button 'Save changes'
          end
        end

        it 'adds translations to user-facing breadcrumbs' do
          visit spotlight.exhibit_browse_index_path(exhibit, locale: 'fr')
          expect(page).to have_breadcrumbs 'Maison', 'parcourir ceci!'
        end

        it 'does not translate admin breadcrumbs' do
          visit spotlight.exhibit_searches_path(exhibit, locale: 'fr')
          expect(page).to have_breadcrumbs 'Home', 'Curation', 'Browse'
        end
      end

      describe 'pages' do
        let!(:about_page1) { FactoryBot.create(:about_page, title: 'First Page', exhibit: exhibit, locale: 'fr') }
        let(:about_page2) { FactoryBot.create(:about_page, title: 'Second Page', exhibit: exhibit, locale: 'fr') }

        before do
          within '.translation-edit-form #general' do
            fill_in 'Home', with: 'Maison'
            fill_in 'About', with: 'Sur'
            click_button 'Save changes'
          end
        end
        it 'adds breadcrumbs to pages' do
          visit spotlight.exhibit_about_page_path(about_page2.exhibit, about_page2, locale: 'fr')
          expect(page).to have_breadcrumbs 'Maison', 'Sur', about_page2.title
        end

        it 'does not translate admin breadcrumbs' do
          visit spotlight.exhibit_about_pages_path(exhibit, locale: 'fr')
          expect(page).to have_breadcrumbs 'Home', 'Curation', 'About'
        end
      end

      describe 'Catalog' do
        before do
          within '.translation-edit-form #general' do
            fill_in 'Home', with: 'Maison'
            fill_in 'Search Results', with: 'Résultats de la recherche'
            click_button 'Save changes'
          end
        end
        it 'adds breadcrumbs user facing catalog' do
          visit spotlight.search_exhibit_catalog_path(exhibit, q: '*', locale: 'fr')
          expect(page).to have_breadcrumbs 'Maison', 'Résultats de la recherche'
        end

        it 'does not translate admin catalog' do
          visit spotlight.admin_exhibit_catalog_path(exhibit, locale: 'fr')
          expect(page).to have_breadcrumbs 'Home', 'Curation', 'Items'
        end
      end
    end
  end

  describe 'Metadata field labels' do
    before { visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr') }

    it 'redirects to the same form tab' do
      click_link 'Metadata field labels'
      within('#metadata', visible: true) do
        fill_in 'Everything', with: 'Tout'
        click_button 'Save changes'
      end

      expect(page).to have_css '.nav-pills li.active', text: 'French'
      expect(page).to have_css '.nav-tabs li.active', text: 'Metadata field labels'
    end

    describe 'configured fields' do
      it 'has a text input for each metadata field' do
        within '#metadata' do
          expect(page).to have_css('input[type="text"]', count: 17)
        end
      end

      it 'allows users to translate both index and show metadata field labels', js: true do
        click_link 'Metadata field labels'

        within('#metadata', visible: true) do
          language_label = find('label', text: 'Language', visible: true)
          language_input = find("##{language_label['for']}", visible: true)
          language_input.set('Langue')
          click_button 'Save changes'
        end

        visit spotlight.search_exhibit_catalog_path(exhibit, f: { language_ssim: ['Latin'] }, locale: 'fr')

        expect(page).to have_css('dt.blacklight-language_ssm', text: 'Langue')

        click_link 'Orbis terrarum tabula recens emendata et in lucem edita'

        expect(page).to have_css('dt.blacklight-language_ssm', text: 'Langue')
      end
    end

    describe 'Exhibit-specific fields' do
      let!(:custom_field) { FactoryBot.create(:custom_field, exhibit: exhibit) }

      before do
        visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
      end

      it 'has text inputs for the exhibit-specific fields' do
        within '#metadata' do
          expect(page).to have_css('input[type="text"]', count: 18)

          within '.translation-exhibit-specific-fields' do
            expect(page).to have_css('input[type="text"]', count: 1)
          end
        end
      end

      it 'allows users to translate exhibit-specific metadata fields' do
        within '#metadata' do
          fill_in custom_field.configuration['label'], with: 'French Custom Field Label'
          click_button 'Save changes'
        end

        # Adding some data to our custom field
        visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352', locale: :fr)
        expect(page).to have_link 'Edit'
        click_on 'Edit'
        fill_in custom_field.configuration['label'], with: 'Custom Field Data'
        click_on 'Save changes'

        expect(page).to have_css('dt', text: 'French Custom Field Label')
        expect(page).to have_css('dd', text: 'Custom Field Data')
      end
    end
  end

  describe 'Search field labels' do
    before { visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr') }

    it 'redirects to the same form tab' do
      click_link 'Search field labels'
      within('#search_fields', visible: true) do
        fill_in 'Everything', with: 'Tout'
        click_button 'Save changes'
      end

      expect(page).to have_css '.nav-pills li.active', text: 'French'
      expect(page).to have_css '.nav-tabs li.active', text: 'Search field labels'
    end

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

    it 'redirects to the same form tab' do
      click_link 'Browse categories'
      within('#browse', visible: true) do
        fill_in 'All Exhibit Items', with: "Tous les objets d'exposition"
        click_button 'Save changes'
      end

      expect(page).to have_css '.nav-pills li.active', text: 'French'
      expect(page).to have_css '.nav-tabs li.active', text: 'Browse categories'
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

  describe 'home page translation table entry' do
    let(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
    let(:about_page) { FactoryBot.create(:about_page, exhibit: exhibit) }
    before do
      exhibit.home_page.clone_for_locale('fr').save
      about_page.clone_for_locale('fr').tap { |p| p.published = true }.save
      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr', tab: 'pages')
    end

    it 'renders a disabled checkbox in the table' do
      # home page should have a disabled checkbox
      expect(page).to have_css('.translation-home-page-settings input[type="checkbox"][disabled]')
      # feature page does not have a translation, so don't use checkbox
      expect(page).not_to have_css('.translation-feature-page-settings input[type="checkbox"]')
      # about page should have a checked checkbox
      expect(page).to have_css('.translation-about-page-settings input[type="checkbox"][checked]')
    end
  end

  describe 'translation progress counter', js: true do
    before do
      FactoryBot.create(:translation, exhibit: exhibit, locale: 'fr', key: "#{exhibit.slug}.title", value: 'Titre')
    end
    it 'counts existing and total available translations' do
      visit spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')
      expect(page).to have_link('General 1/8')
      expect(page).to have_link('Search field labels 0/16')
      expect(page).to have_link('Browse categories 0/2')
      expect(page).to have_link('Metadata field labels 0/17')
    end
  end
end
