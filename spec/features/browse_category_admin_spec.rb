# frozen_string_literal: true

describe 'Browse Category Administration', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let!(:search) { FactoryBot.create(:search, exhibit:, query_params: { f: { 'genre_ssim' => ['Value'] } }) }

  before { login_as curator }

  describe 'index' do
    it 'has searches' do
      visit spotlight.exhibit_searches_path(exhibit)
      expect(page).to have_css('.card-title', text: search.title)
    end
  end

  describe 'create' do
    it 'creates a new browse category with the current search parameters', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
      click_button 'Save this search'
      expect(page).to have_css('#save-modal')
      fill_in 'search_title', with: 'Some search'
      expect do
        find('input[name="commit"]').click
        sleep 1 # Test fails without this after move to Propshaft.
        exhibit.searches.reload
        sleep 1 # Test fails without this after move to Propshaft.
      end.to change { exhibit.searches.count }.by 1
      expect(exhibit.searches.last.query_params).to eq 'q' => 'xyz'
    end

    it 'updates an existing browse category with the current search parameters', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
      click_button 'Save this search'
      expect(page).to have_css('#save-modal')
      select search.title, from: 'id'
      find('input[name="commit"]').click
      sleep 1 # Test fails without this after move to Propshaft.
      expect(search.reload.query_params).to eq 'q' => 'xyz'
    end
  end

  describe 'edit' do
    it 'displays an edit form' do
      visit spotlight.edit_exhibit_search_path(exhibit, search)
      expect(page).to have_css('h1 small', text: 'Edit browse category')
      expect(find_field('search_title').value).to eq search.title
      within '.appliedParams' do
        expect(page).to have_content 'Genre'
        expect(page).to have_content 'Value'
      end
    end

    describe 'with a group present' do
      let!(:group) { FactoryBot.create(:group, exhibit:, title: 'Good group') }

      it 'enables group selection' do
        visit spotlight.edit_exhibit_search_path(exhibit, search)
        click_link 'Group'
        expect(page).to have_content 'You can add this browse category'

        within '#search-group' do
          expect(find('input[type="checkbox"]')).not_to be_checked
          check 'Good group'
        end

        click_button 'Save changes'
        expect(page).to have_content('The browse category was successfully updated.')
        visit spotlight.edit_exhibit_search_path(exhibit, search)
        click_link 'Group'

        within '#search-group' do
          expect(find('input[type="checkbox"]')).to be_checked
        end
      end
    end

    describe 'without a group present' do
      it 'displays no group help text' do
        visit spotlight.edit_exhibit_search_path(exhibit, search)
        click_link 'Group'
        expect(page).to have_content 'You cannot add this browse category'
      end
    end

    it 'attaches a masthead image' do
      visit spotlight.edit_exhibit_search_path exhibit, search

      click_link 'Masthead'

      within '#search-masthead' do
        choose 'Upload an image'
        # attach_file('search_masthead_attributes_file', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
        # The JS fills in these fields:
        find_by_id('search_masthead_attributes_iiif_tilesource', visible: false).set 'http://test.host/images/7'
        find_by_id('search_masthead_attributes_iiif_region', visible: false).set '0,0,100,200'
      end

      click_button 'Save changes'

      expect(page).to have_content('The browse category was successfully updated.')

      search.reload

      expect(search.masthead).not_to be_nil
      expect(search.masthead.iiif_url).to eq 'http://test.host/images/7/0,0,100,200/1800,180/0/default.jpg'
    end

    it 'attaches a thumbnail image' do
      visit spotlight.edit_exhibit_search_path exhibit, search

      click_link 'Thumbnail'

      within '#search-thumbnail' do
        choose 'Upload an image'
        attach_file('search_thumbnail_attributes_file', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
      end

      click_button 'Save changes'

      expect(page).to have_content('The browse category was successfully updated.')

      search.reload

      expect(search.thumbnail).not_to be_nil
    end

    it 'can configure a search box' do
      visit spotlight.edit_exhibit_search_path exhibit, search
      expect(search.search_box).to eq false

      check 'Display search box'

      click_button 'Save changes'
      expect(page).to have_content('The browse category was successfully updated.')
      search.reload

      expect(search.search_box).to eq true
    end

    it 'can select a default index view type' do
      visit spotlight.edit_exhibit_search_path exhibit, search
      choose 'List'

      click_button 'Save changes'

      expect(page).to have_content('The browse category was successfully updated.')

      search.reload

      expect(search.default_index_view_type).to eq 'list'
    end
  end

  describe 'destroy' do
    it 'destroys a tag' do
      skip('TODO: Allow searches to be destroyed without javascript')
      visit spotlight.exhibit_searches_path(exhibit)
      within('.card .search') do
        click_link('Delete')
      end
      expect(page).to have_content('Search was deleted')
      expect(page).to have_no_content(search.title)
    end
  end
end
