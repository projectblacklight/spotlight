require 'spec_helper'

describe 'Multi image selector', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it 'allows the user to select which image in a multi image object to display' do
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    add_widget 'solr_documents'

    fill_in_typeahead_field with: 'xd327cm9378'

    expect(page).to have_selector '.panel'

    within('.panel') do
      expect(page).to have_content(/Image \d of \d/)
      expect(page).to have_link 'Change'
    end

    save_page

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0001_thumb']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0002_thumb']")

    click_link('Edit')

    within('.panel') do
      expect(page).to have_content(/Image \d of \d/)
      find('a', text: 'Change').trigger('click')
    end

    expect(page).to have_css('.thumbs-list ul', visible: true)

    within('.thumbs-list ul') do
      all('li')[1].trigger('click')
    end

    save_page

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0001_thumb']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0002_thumb']")
  end
end
