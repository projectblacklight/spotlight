# frozen_string_literal: true

describe 'Multi image selector', type: :feature, js: true, versioning: true, default_max_wait_time: 5 do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it 'allows the user to select which image in a multi image object to display' do
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    add_widget 'solr_documents' # the "Item Row" widget

    fill_in_typeahead_field with: 'xd327cm9378'

    expect(page).to have_selector '.panel'

    within('.panel') do
      expect(page).to have_content(/Image \d of \d/)
      expect(page).to have_link 'Change'
    end

    save_page

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)
    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0001/full/!400,400/0/default.jpg']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0002/full/!400,400/0/default.jpg']")

    click_link('Edit')

    within('.panel') do
      expect(page).to have_content(/Image \d of \d/)
      find('a', text: 'Change').click
    end

    expect(page).to have_css('.thumbs-list ul', visible: true)

    within('.thumbs-list ul') do
      all('li')[1].click
    end

    save_page

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0001/full/!400,400/0/default.jpg']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0002/full/!400,400/0/default.jpg']")
  end
end
