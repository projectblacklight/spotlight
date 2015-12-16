require 'spec_helper'

feature 'Reindex Monitor', js: true do
  let(:resources) do
    [FactoryGirl.create(:resource, updated_at: Time.zone.now, index_status: 1)]
  end
  let(:exhibit) { FactoryGirl.create(:exhibit, resources: resources) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
    visit spotlight.admin_exhibit_catalog_index_path(exhibit)
  end

  it 'is rendered on the item admin page' do
    expect(page).to have_css('.panel.index-status', visible: true)
    within('.panel.index-status') do
      expect(page).to have_css('p', text: /Began reindexing a total of \d items/)
      expect(page).to have_css('p', text: /Reindexed \d of \d items/)
    end
  end
end
