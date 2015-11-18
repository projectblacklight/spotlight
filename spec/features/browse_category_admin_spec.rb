require 'spec_helper'

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
        attach_file('search_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
      end

      click_button 'Save changes'

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.masthead).not_to be nil
      expect(search.masthead.image.cropped).not_to be_nil
      expect(search.masthead.image.path).to end_with 'avatar.png'
    end

    it 'attaches a thumbnail image' do
      visit spotlight.edit_exhibit_search_path exhibit, search

      click_link 'Thumbnail'

      within '#search-thumbnail' do
        choose 'Upload an image'
        attach_file('search_thumbnail_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
      end

      click_button 'Save changes'

      expect(page).to have_content('The search was successfully updated.')

      search.reload

      expect(search.thumbnail).not_to be nil
      expect(search.thumbnail.image.thumb).not_to be_nil
      expect(search.thumbnail.image.path).to end_with 'avatar.png'
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
