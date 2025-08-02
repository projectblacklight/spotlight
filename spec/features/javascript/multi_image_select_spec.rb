# frozen_string_literal: true

RSpec.describe 'Multi image selector', js: true, max_wait_time: 5, type: :feature, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }

  before { login_as exhibit_curator }

  it 'allows the user to select which image in a multi image object to display' do
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    add_widget 'solr_documents' # the "Item Row" widget

    fill_in_typeahead_field with: 'xd327cm9378'

    expect(page).to have_selector '.card'

    within('.card') do
      expect(page).to have_content(/Image \d of \d/)
      expect(page).to have_link 'Change'
    end

    save_page_changes

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0001/full/!400,400/0/default.jpg']")
    expect(page).to have_no_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0002/full/!400,400/0/default.jpg']")

    click_link('Edit')
    wait_for_sir_trevor

    expect(page).to have_content(/Image \d of \d/)
    click_link 'Change'

    # Wait for the animation to finish
    expect(page).to have_css('.thumbs-list[style=""]', visible: true)
    within('.thumbs-list ul') do
      all('li')[1].click
    end

    # Wait for the hidden input to be updated before saving
    expect(page).to have_css('input[name="item[item_0][iiif_canvas_id]"][value="https://purl.stanford.edu/xd327cm9378/iiif/canvas/cocina-fileSet-xd327cm9378-xd327cm9378_2"]',
                             visible: false)
    save_page_changes

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to have_no_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0001/full/!400,400/0/default.jpg']")
    expect(page).to have_css("img[src='https://stacks.stanford.edu/image/iiif/xd327cm9378%2Fxd327cm9378_05_0002/full/!400,400/0/default.jpg']")
  end
end
