# frozen_string_literal: true

feature 'Reindex Monitor', js: true, default_max_wait_time: 10 do
  let(:resources) do
    [FactoryBot.create(:resource)]
  end
  let(:exhibit) { FactoryBot.create(:exhibit, resources: resources) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before do
    FactoryBot.create(:in_progress_reindexing_log_entry, exhibit: exhibit, items_reindexed_estimate: 5)
    login_as exhibit_curator
    visit spotlight.admin_exhibit_catalog_path(exhibit)
  end

  it 'is rendered on the item admin page' do
    expect(page).to have_css('.panel.index-status', visible: true)
    within('.panel.index-status') do
      expect(page).to have_css('p', text: /Began reindexing a total of \d+ items/)
      expect(page).to have_css('p', text: /Reindexed \d+ of \d+ items/)
    end
  end
end
