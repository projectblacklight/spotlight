require 'spec_helper'

describe 'Tags Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:tagging) { FactoryGirl.create(:tagging, tagger: exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe 'index' do
    it 'has tags' do
      visit spotlight.exhibit_tags_path(exhibit)
      expect(page).to have_css('td', text: tagging.tag.name)
    end

    it 'links tags to a search' do
      visit spotlight.exhibit_tags_path(exhibit)
      click_on tagging.tag.name
      expect(page).to have_content "Remove constraint Exhibit Tags: #{tagging.tag.name}"
    end
  end

  describe 'destroy' do
    it 'destroys a tag' do
      visit spotlight.exhibit_tags_path(exhibit)
      click_link 'Delete'
      expect(page).not_to have_css('td', text: tagging.tag.name)
    end
  end
end
