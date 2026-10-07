# frozen_string_literal: true

RSpec.describe 'Exhibits index page', type: :feature do
  context 'with multiple exhibits' do
    let!(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }
    let!(:other_exhibit) { FactoryBot.create(:exhibit, title: 'Some Other Title') }

    it 'shows some cards for each published exhibit' do
      visit spotlight.exhibits_path

      expect(page).to have_css '.exhibit-card h2', text: 'Some Exhibit Title'
    end

    context 'with tagged exhibits' do
      before do
        exhibit.tag_list = %w[a]
        other_exhibit.tag_list = %w[a b]

        exhibit.save
        other_exhibit.save
      end

      it 'shows controls to filter exhibits by tags' do
        visit spotlight.exhibits_path

        expect(page).to have_css '.exhibit-card', count: 2

        within '.tags' do
          expect(page).to have_css '.active', text: 'All'

          click_link 'a'
        end

        expect(page).to have_css '.exhibit-card', count: 2

        within '.tags' do
          expect(page).to have_css '.active', text: 'a'
          click_link 'b'
        end

        expect(page).to have_css '.exhibit-card', count: 1
      end

      it 'searches within the selected tag', :js do
        exhibit.update(title: 'Some Other Exhibit')
        visit spotlight.exhibits_path(tag: 'b')

        fill_in 'Search exhibits', with: 'other'

        expect(page).to have_css '#exhibit-search-status', text: '1 exhibit matches “other”.'
        expect(page).to have_css '.exhibit-card', count: 1
        expect(page).to have_css '.tags .active', text: 'b'
      end

      it 'disables the tags without any matches', :js do
        visit spotlight.exhibits_path

        fill_in 'Search exhibits', with: 'some exhibit'

        expect(page).to have_css '#exhibit-search-status', text: '1 exhibit matches “some exhibit”.'
        expect(page).to have_css '.tags .nav-link.disabled', text: 'b'
        expect(page).to have_link 'a'
      end

      it 'reports no matches in the selected tag', :js do
        visit spotlight.exhibits_path(tag: 'b')

        fill_in 'Search exhibits', with: 'some exhibit'

        expect(page).to have_text 'No exhibits match “some exhibit”.'
        expect(page).to have_css '.tags .active', text: 'b'
        expect(page).to have_link 'a'
      end
    end

    it 'filters the exhibits as the user types', :js do
      visit spotlight.exhibits_path

      within 'search' do
        fill_in 'Search exhibits', with: 'other title'
        expect(page).to have_css '[role="status"]', text: '1 exhibit matches “other title”.'
      end

      expect(page).to have_css '.exhibit-card', count: 1
      expect(page).to have_css '.exhibit-card .card-title mark', text: 'Other'
      expect(page).to have_css '.exhibit-card .card-title mark', text: 'Title'
      expect(page).to have_current_path(spotlight.exhibits_path(q: 'other title'))
      expect(page).to have_field 'Search exhibits', focused: true
      expect(page).to be_axe_clean.within('search', '#content').according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :wcag22aa)

      find_field('Search exhibits').send_keys(*([:backspace] * 'other title'.length))

      expect(page).to have_css '#exhibit-search-status', text: 'Showing all exhibits.'
      expect(page).to have_css '.exhibit-card', count: 2
      expect(page).to have_no_css '.exhibit-card mark'
      expect(page).to have_current_path(spotlight.exhibits_path)
    end

    it 'clears the search with the Escape key', :js do
      visit spotlight.exhibits_path

      fill_in 'Search exhibits', with: 'other'
      expect(page).to have_css '.exhibit-card', count: 1
      find_field('Search exhibits').send_keys(:escape)

      expect(page).to have_field 'Search exhibits', with: '', focused: true
      expect(page).to have_css '#exhibit-search-status', exact_text: 'Showing all exhibits.'
      expect(page).to have_css '.exhibit-card', count: 2
    end

    it 'filters the exhibits when the user presses Enter', :js do
      visit spotlight.exhibits_path

      fill_in 'Search exhibits', with: 'other'
      find_field('Search exhibits').send_keys(:enter)

      expect(page).to have_css '.exhibit-card', count: 1
      expect(page).to have_css '.exhibit-card h2', text: 'Some Other Title'
      expect(page).to have_css '#exhibit-search-status', text: '1 exhibit matches “other”.'
    end
  end

  context 'with a site admin', :js do
    before do
      FactoryBot.create(:exhibit, title: 'Published Maps')
      FactoryBot.create(:exhibit, title: 'Unpublished Maps', published: false)
      FactoryBot.create(:exhibit, title: 'Unpublished Islands', published: false)
      login_as FactoryBot.create(:site_admin)
    end

    it 'announces the number of matches in the selected tab' do
      visit spotlight.exhibits_path

      fill_in 'Search exhibits', with: 'maps'
      expect(page).to have_css '#exhibit-search-status', exact_text: '1 published exhibit matches “maps”.'

      click_link 'Unpublished exhibits'
      expect(page).to have_css '#exhibit-search-status', exact_text: '1 unpublished exhibit matches “maps”.'
      expect(page).to have_css '#unpublished .exhibit-card', count: 1

      fill_in 'Search exhibits', with: 'islands'
      expect(page).to have_css '#exhibit-search-status', exact_text: '1 unpublished exhibit matches “islands”.'
      expect(page).to have_css '#unpublished.active .exhibit-card h2', text: 'Unpublished Islands'

      click_link 'Published exhibits'
      expect(page).to have_css '#exhibit-search-status', exact_text: 'No published exhibits match “islands”.'
    end
  end

  context 'with a single exhibit' do
    let!(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }

    it 'redirects to the exhibit home page' do
      visit spotlight.exhibits_path

      expect(current_url).to eq spotlight.exhibit_root_url(exhibit)
    end
  end
end
