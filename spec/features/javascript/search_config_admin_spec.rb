require 'spec_helper'

feature 'Search Configuration Administration', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as user }

  describe 'search fields' do
    it 'allows the curator to disable all search fields' do
      visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
      expect(page).to have_css 'select#search_field'

      click_link user.email
      within '#user-util-collapse .dropdown' do
        click_link 'Dashboard'
      end
      click_link 'Search'
      click_link 'Options'

      uncheck 'Display search box'

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')

      expect(page).not_to have_css 'select#search_field'
    end

    it 'allows the curator to update search field options' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Search'

      click_link 'Options'

      within('#nested-search-fields') do
        expect(page).to have_css("#blacklight_configuration_search_fields_title_label[type='hidden']", visible: false)
        expect(page).not_to have_css("#blacklight_configuration_search_fields_title_label[type='text']")
        click_link('Title')
        expect(page).not_to have_css("#blacklight_configuration_search_fields_title_label[type='hidden']")
        expect(page).to have_css("#blacklight_configuration_search_fields_title_label[type='text']")
        fill_in 'blacklight_configuration_search_fields_title_label', with: 'My Title Label'
      end

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')
      expect(page).to have_select 'Search in', with_options: ['My Title Label']
    end
  end

  describe 'facets' do
    it 'allows us to update the label with edit-in-place' do
      input_id = 'blacklight_configuration_facet_fields_genre_ssim_label'
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Search'

      click_link 'Facets'

      facet = find('.edit-in-place', text: 'Genre')
      expect(page).not_to have_content('Topic')
      expect(page).to have_css("input##{input_id}", visible: false)

      facet.click

      expect(page).to have_css("input##{input_id}", visible: true)

      fill_in(input_id, with: 'Topic')

      click_button 'Save changes'
      click_link 'Facets'

      expect(page).to have_content('The exhibit was successfully updated.')

      expect(page).not_to have_content('Genre')
      expect(page).to have_content('Topic')
    end

    it 'allows the curator to select a different facet sort order' do
      visit spotlight.edit_exhibit_search_configuration_path(exhibit)
      click_link 'Facets'

      within '.facet-config-genre_ssim' do
        click_link 'Options'
        expect(find(:css, '#blacklight_configuration_facet_fields_genre_ssim_sort_count')).to be_checked

        choose 'Value'
      end

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')

      exhibit.reload
      expect(exhibit.blacklight_config.facet_fields['genre_ssim'].sort).to eq 'index'
    end
  end

  describe 'results' do
    it 'updates search result options' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Search'

      click_link 'Results'

      uncheck 'List'

      choose '20'

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')

      click_link 'Results'

      expect(field_labeled('List')).to_not be_checked
      expect(field_labeled('Gallery')).to be_checked

      expect(field_labeled('20')).to be_checked
      expect(field_labeled('10')).to_not be_checked
    end
    it 'updates Sort field result options' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Search'

      click_link 'Results'

      within('#nested-sort-fields') do
        expect(page).to have_css("#blacklight_configuration_sort_fields_title_label[type='hidden']", visible: false)
        expect(page).not_to have_css("#blacklight_configuration_sort_fields_title_label[type='text']")
        click_link('Title')
        expect(page).not_to have_css("#blacklight_configuration_sort_fields_title_label[type='hidden']")
        expect(page).to have_css("#blacklight_configuration_sort_fields_title_label[type='text']")
        fill_in 'blacklight_configuration_sort_fields_title_label', with: 'My Title Label'
      end

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')

      click_link 'Results'

      within('#nested-sort-fields') do
        expect(page).to have_css('h3', text: 'My Title Label')
      end
    end # Sort field
  end # results tab
end
