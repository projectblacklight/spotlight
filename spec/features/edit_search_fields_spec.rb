require 'spec_helper'

describe 'Search Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as exhibit_admin }

  describe 'edit' do
    it 'displays the search configuration edit screen' do
      visit spotlight.edit_exhibit_search_configuration_path(exhibit)
      expect(page).to have_css('h1 small', text: 'Search')
    end

    it 'has breadcrumbs' do
      visit spotlight.edit_exhibit_search_configuration_path exhibit
      expect(page).to have_breadcrumbs 'Home', 'Configuration', 'Search'
    end

    describe 'facets' do
      it 'displays information about the facets' do
        visit spotlight.edit_exhibit_search_configuration_path(exhibit)
        within("[data-id='genre_ssim']") do
          expect(page).to have_content('Genre')
          expect(page).to have_content(/\d+ items/)
          expect(page).to have_content(/(\d+) unique values/)
        end
      end

      it 'allows curators to select and unselect facets for display' do
        visit spotlight.edit_exhibit_search_configuration_path exhibit

        expect(page).to have_content 'Configuration Search Options Facets'
        expect(page).to have_button 'Save'

        uncheck 'blacklight_configuration_facet_fields_language_ssim_show' # Language
        uncheck 'blacklight_configuration_facet_fields_genre_ssim_show' # Genre
        check 'blacklight_configuration_facet_fields_subject_temporal_ssim_show' # Era

        click_on 'Save changes'

        expect(exhibit.reload.blacklight_config.facet_fields.select { |_k, v| v.show }.keys).to include('subject_temporal_ssim')
        expect(exhibit.blacklight_config.facet_fields.select { |_k, v| v.show }.keys).to_not include('language_ssim', 'genre_ssim')
      end
    end

    describe 'sort' do
      it 'displays the sort fields edit area' do
        visit spotlight.edit_exhibit_search_configuration_path(exhibit)
        expect(page).to have_content('Sort fields')
      end

      it 'updates sort options' do
        visit spotlight.edit_exhibit_search_configuration_path(exhibit)

        # #field_labeled doesn't appear to work for disabled inputs
        expect(page).to have_css("input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']")
        expect(page).to have_css('#nested-sort-fields .dd-item:nth-child(5) h3', text: 'Identifier')

        uncheck 'blacklight_configuration_sort_fields_title_enabled'
        uncheck 'blacklight_configuration_sort_fields_identifier_enabled'

        find('#blacklight_configuration_sort_fields_type_weight').set('100')

        click_button 'Save changes'

        click_link 'Results'

        expect(page).to have_css("input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']")
        expect(find('#blacklight_configuration_sort_fields_type_enabled')).to be_checked
        expect(find('#blacklight_configuration_sort_fields_date_enabled')).to be_checked
        expect(find('#blacklight_configuration_sort_fields_title_enabled')).to_not be_checked
        expect(find('#blacklight_configuration_sort_fields_identifier_enabled')).to_not be_checked

        # Type is now sorted last
        expect(page).to have_css('#nested-sort-fields .dd-item:nth-child(5) h3', text: 'Type')
      end
    end
  end
end
