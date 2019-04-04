# frozen_string_literal: true

require 'spec_helper'

describe 'adding IIIF Manifest', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as curator }

  it 'has form to add IIIF Manifests' do
    visit spotlight.admin_exhibit_catalog_path(exhibit)
    click_link 'Add items'

    expect(page).to have_link('IIIF URL') # tab name
    expect(page).to have_css("input[id='resource_url'][type='text']")
    expect(page).to have_content 'Add the URL of a IIIF manifest or collection'
    expect(page).to have_button 'Add IIIF items'
  end

  it 'submits the form to create a new item' do
    expect_any_instance_of(Spotlight::Resource).to receive(:reindex_later).and_return(true)
    url = 'https://purl.stanford.edu/vw754mr2281/iiif/manifest'
    stub_request(:head, url).to_return(status: 200, headers: { 'Content-Type' => 'application/json' })
    visit spotlight.admin_exhibit_catalog_path(exhibit)

    click_link 'Add items'
    fill_in 'URL', with: url

    click_button 'Add IIIF items'

    expect(Spotlight::Resource.last.url).to eq url
  end

  it 'returns an error message if the URL returned in not a IIIF endpoint' do
    visit spotlight.admin_exhibit_catalog_path(exhibit)
    stub_request(:head, 'http://example.com').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })

    click_link 'Add items'
    fill_in 'URL', with: 'http://example.com'

    click_button 'Add IIIF items'

    expect(page).to have_css('.alert', text: 'Invalid IIIF URL')
  end
end
