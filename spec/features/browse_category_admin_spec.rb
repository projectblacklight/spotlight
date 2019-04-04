# frozen_string_literal: true

describe 'Browse Category Administration', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let!(:search) { FactoryBot.create(:search, exhibit: exhibit, query_params: { f: { 'genre_ssim' => ['Value'] } }) }
  before { login_as curator }

  describe 'index' do
    it 'has searches' do
      visit spotlight.exhibit_searches_path(exhibit)
      expect(page).to have_css('.panel .search .title', text: search.title)
    end
  end

  describe 'create' do
    it 'creates a new browse category with the current search parameters', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
      click_button 'Save this search'
      expect(page).to have_css('#save-modal')
      fill_in 'search_title', with: 'Some search'
      expect do
        click_button 'Save'
        exhibit.searches.reload
      end.to change { exhibit.searches.count }.by 1
      expect(exhibit.searches.last.query_params).to eq 'q' => 'xyz'
    end
    it 'updates an existing browse category with the current search parameters', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
      click_button 'Save this search'
      expect(page).to have_css('#save-modal')
      select search.title, from: 'id'
      click_button 'Save'
      expect(search.reload.query_params).to eq 'q' => 'xyz'
    end
  end

  describe 'edit' do
    it 'displays an edit form' do
      visit spotlight.edit_exhibit_search_path(exhibit, search)
      expect(page).to have_css('h1 small', text: 'Edit Browse Category')
      expect(find_field('search_title').value).to eq search.title
      within '.appliedFilter' do
        expect(page).to have_content 'Genre'
        expect(page).to have_content 'Value'
      end
    end

    it 'attaches a masthead image' do
      visit spotlight.edit_exhibit_search_path exhibit, search

      click_link 'Masthead'

      within '#search-masthead' do
        choose 'Upload an image'
        # attach_file('search_masthead_attributes_file', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
        # The JS fills in these fields:
        find('#search_masthead_attributes_iiif_tilesource', visible: false).set 'http://test.host/images/7'
        find('#search_masthead_attributes_iiif_region', visible: false).set '0,0,100,200'
      end

      click_button 'Save changes'

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.masthead).not_to be nil
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

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.thumbnail).not_to be nil
    end

    it 'can configure a search box' do
      visit spotlight.edit_exhibit_search_path exhibit, search
      expect(search.search_box).to eq false

      check 'Display search box'

      click_button 'Save changes'
      expect(page).to have_content('The search was successfully updated.')
      search.reload

      expect(search.search_box).to eq true
    end

    it 'can select a default index view type' do
      visit spotlight.edit_exhibit_search_path exhibit, search
      choose 'List'

      click_button 'Save changes'

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.default_index_view_type).to eq 'list'
    end
  end

  describe 'destroy' do
    it 'destroys a tag' do
      skip('TODO: Allow searches to be destroyed without javascript')
      visit spotlight.exhibit_searches_path(exhibit)
      within('.panel .search') do
        click_link('Delete')
      end
      expect(page).to have_content('Search was deleted')
      expect(page).not_to have_content(search.title)
    end
  end
end
