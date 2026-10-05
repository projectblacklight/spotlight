# frozen_string_literal: true

RSpec.describe 'Exhibits index page', type: :feature do
  context 'with multiple exhibits' do
    let!(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }
    let!(:other_exhibit) { FactoryBot.create(:exhibit, title: 'Some Other Title') }

    it 'shows some cards for each published exhibit' do
      visit spotlight.exhibits_path

      expect(page).to have_css '.exhibit-card h2', text: 'Some Exhibit Title'
    end

    context 'with an unlisted exhibit' do
      let!(:unlisted_exhibit) { FactoryBot.create(:exhibit, title: 'Some Unlisted Title', listed: false) }

      it 'is left out of the listing but can still be viewed by its URL' do
        visit spotlight.exhibits_path

        expect(page).to have_css '.exhibit-card h2', text: 'Some Exhibit Title'
        expect(page).to have_no_css '.exhibit-card h2', text: 'Some Unlisted Title'

        visit spotlight.exhibit_path(unlisted_exhibit)
        expect(page).to have_css 'h1', text: 'Some Unlisted Title'
        expect(page).to have_css 'meta[name="robots"][content="noindex"]', visible: false
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
    end
  end

  context 'with a single exhibit' do
    let!(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }

    it 'redirects to the exhibit home page' do
      visit spotlight.exhibits_path

      expect(current_url).to eq spotlight.exhibit_root_url(exhibit)
    end
  end

  context 'with a single unlisted exhibit' do
    before { FactoryBot.create(:exhibit, title: 'Some Unlisted Title', listed: false) }

    it 'does not redirect anonymous visitors to the unlisted exhibit' do
      visit spotlight.exhibits_path

      expect(current_url).to eq spotlight.exhibits_url
      expect(page).to have_no_css '.exhibit-card h2', text: 'Some Unlisted Title'
    end
  end

  context 'with an unlisted exhibit and an unpublished exhibit' do
    before do
      FactoryBot.create(:exhibit, title: 'Some Unlisted Title', listed: false)
      FactoryBot.create(:exhibit, title: 'Some Unpublished Title', published: false)
      login_as FactoryBot.create(:site_admin)
    end

    it 'shows the exhibits index with tabs for each instead of redirecting' do
      visit spotlight.exhibits_path

      expect(current_url).to eq spotlight.exhibits_url
      expect(page).to have_link 'Preview exhibits'
      expect(page).to have_link 'Unpublished exhibits'
      expect(page).to have_css '#unlisted .exhibit-card h2', text: 'Some Unlisted Title', visible: :all
      expect(page).to have_css '#unpublished .exhibit-card h2', text: 'Some Unpublished Title', visible: :all
    end
  end
end
