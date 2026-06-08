# frozen_string_literal: true

RSpec.describe 'Oembed and text block', feature: true, max_wait_time: 15, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:feature_page) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit:
    )
  end

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'oembed'
  end

  it 'allows you to add the oembed block widget', js: true do
    expect(page).to have_text 'This widget embeds an oEmbed-supported web resource and a text block to the left or right of it.'
    expect(page).to have_text 'Examples of oEmbed-supported resources include those from YouTube, Twitter, Flickr, and SlideShare.'
    expect(page).to have_text 'Display text on'
    expect(page).to have_text 'URL'
    expect(page).to have_text 'Text'
  end
end
