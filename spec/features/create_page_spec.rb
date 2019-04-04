# frozen_string_literal: true

describe 'Creating a page', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  describe 'when a bunch of about pages exist' do
    let!(:page1) { FactoryBot.create(:about_page, exhibit: exhibit) }
    let!(:page2) { FactoryBot.create(:about_page, exhibit: exhibit) }
    let!(:page3) { FactoryBot.create(:about_page, exhibit: exhibit, title: 'A new one') }
    it 'is able to show a list of About pages to be curated' do
      login_as exhibit_curator
      visit spotlight.exhibit_dashboard_path(exhibit)
      within '#sidebar' do
        click_link 'About pages'
      end
      expect(page).to have_content 'A new one'
    end
  end
end
