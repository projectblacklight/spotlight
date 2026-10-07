# frozen_string_literal: true

RSpec.describe 'Exhibits index page', type: :feature do
  context 'with multiple exhibits' do
    let!(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }
    let!(:other_exhibit) { FactoryBot.create(:exhibit, title: 'Some Other Title') }

    it 'shows some cards for each published exhibit' do
      visit spotlight.exhibits_path

      expect(page).to have_css '.exhibit-card h2', text: 'Some Exhibit Title'
    end

    it 'searches the exhibits' do
      visit spotlight.exhibits_path
      fill_in 'Search exhibits', with: 'other'
      click_button 'Search exhibits'

      expect(page).to have_css '.exhibit-card', count: 1
      expect(page).to have_css '.exhibit-card h2', text: 'Some Other Title'
    end

    it 'shows a message when no exhibits match the search' do
      visit spotlight.exhibits_path(q: 'unrelated')

      expect(page).to have_text 'No exhibits match your search.'
    end

    context 'with the live filter', :js do
      it 'filters the exhibits as the user types, without a page load' do
        visit spotlight.exhibits_path
        page.execute_script('window.beforeFilter = true')
        fill_in 'Search exhibits', with: 'other'

        expect(page).to have_css '.exhibit-card', count: 1
        expect(page).to have_current_path(/q=other/)
        expect(page.evaluate_script('window.beforeFilter')).to be true
      end

      it 'tells screen readers how many exhibits match' do
        visit spotlight.exhibits_path
        fill_in 'Search exhibits', with: 'other'

        expect(page).to have_css '[role="status"]', text: '1 exhibit matches your search.', visible: :all
      end

      it 'clears the search when the user presses Escape' do
        visit spotlight.exhibits_path(q: 'other')
        find_field('Search exhibits').send_keys(:escape)

        expect(page).to have_css '.exhibit-card', count: 2
        expect(page).to have_field 'Search exhibits', with: ''
      end
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

      it 'keeps the search query when the user selects a tag' do
        visit spotlight.exhibits_path(q: 'other')

        within('.tags') { click_link 'a' }
        expect(page).to have_css '.exhibit-card', count: 1

        within('.tags') { click_link 'All' }
        expect(page).to have_css '.exhibit-card', count: 1
        expect(page).to have_field 'Search exhibits', with: 'other'
      end

      it 'disables the tags without exhibits that match the search' do
        visit spotlight.exhibits_path(q: 'exhibit')

        within '.tags' do
          expect(page).to have_link 'a'
          expect(page).to have_no_link 'b'
          expect(page).to have_css '[aria-disabled="true"]', text: 'b'
        end
      end

      it 'enables tags with matches outside the selected tag, and the selected tag' do
        visit spotlight.exhibits_path(q: 'exhibit', tag: 'b')

        expect(page).to have_text 'No exhibits match your search.'
        within '.tags' do
          expect(page).to have_link 'a'
          expect(page).to have_link 'b'
        end
      end

      it 'keeps the selected tag when the user searches' do
        visit spotlight.exhibits_path(tag: 'b')
        fill_in 'Search exhibits', with: 'some'
        click_button 'Search exhibits'

        expect(page).to have_css '.exhibit-card', count: 1
        expect(page).to have_css '.exhibit-card h2', text: 'Some Other Title'
      end
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
