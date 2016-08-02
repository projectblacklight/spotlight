describe 'Browse Category Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:search) { FactoryGirl.create(:search, exhibit: exhibit, query_params: { f: { 'genre_ssim' => ['Value'] } }) }
  before { login_as curator }
  describe 'index' do
    it 'has searches' do
      visit spotlight.exhibit_searches_path(exhibit)
      expect(page).to have_css('.panel .search .title', text: search.title)
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
        masthead = FactoryGirl.create(:masthead)
        fill_in 'search_masthead_attributes_iiif_url', with: 'http://test.host/images/7/0,0,100,200/full/0/default.jpg'
        find('#search_masthead_id', visible: false).set masthead.id
      end

      click_button 'Save changes'

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.masthead).not_to be nil
      expect(search.masthead.iiif_url).to eq 'http://test.host/images/7/0,0,100,200/full/0/default.jpg'
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
