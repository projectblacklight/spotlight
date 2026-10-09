# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'adding IIIF Manifest', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  before { login_as curator }

  it 'submits the form to create a new item' do
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex_later).and_return(true)
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
