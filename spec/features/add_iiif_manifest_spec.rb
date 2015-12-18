require 'rails_helper'

describe 'adding IIIF Manifest', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as curator }

  it 'has form to add IIIF Manifests' do
    visit spotlight.admin_exhibit_catalog_index_path(exhibit)
    click_link 'Add repository item'

    expect(page).to have_link('IIIF Manifest') # tab name
    expect(page).to have_css("input[id='resource_url'][type='text']")
    expect(page).to have_content 'Add the URL of a IIIF manifest'
    expect(page).to have_button 'Add IIIF manifest URLs'
  end

  it 'submits the form to create a new item' do
    expect_any_instance_of(Spotlight::Resource).to receive(:reindex_later)
    url = 'https://purl.stanford.edu/vw754mr2281/iiif/manifest.json'
    visit spotlight.admin_exhibit_catalog_index_path(exhibit)

    click_link 'Add repository item'
    fill_in 'Manifest', with: url

    click_button 'Add IIIF manifest URLs'

    expect(Spotlight::Resource.last.url).to eq url
  end
end
