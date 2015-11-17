require 'spec_helper'

describe 'Exhibits index page', type: :feature do
  context 'with multiple exhibits' do
    let!(:exhibit) { FactoryGirl.create(:exhibit, title: 'Some Exhibit Title') }
    let!(:other_exhibit) { FactoryGirl.create(:exhibit, title: 'Some Other Title') }

    it 'shows some cards for each published exhibit' do
      visit spotlight.exhibits_path

      within '.exhibit-card:first' do
        expect(page).to have_selector 'h2', text: 'Some Exhibit Title'
      end
    end
  end

  context 'with a single exhibit' do
    let!(:exhibit) { FactoryGirl.create(:exhibit, title: 'Some Exhibit Title') }

    it 'redirects to the exhibit home page' do
      visit spotlight.exhibits_path

      expect(current_url).to eq spotlight.exhibit_root_url(exhibit)
    end
  end
end
