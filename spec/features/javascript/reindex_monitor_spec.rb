# frozen_string_literal: true

describe 'Reindex Monitor', default_max_wait_time: 10, js: true do
  let(:resources) do
    FactoryBot.create_list(:resource, 1)
  end
  let(:exhibit) { FactoryBot.create(:exhibit, resources: resources) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
    visit spotlight.admin_exhibit_catalog_path(exhibit)
    ActionCable.server.broadcast 'progress_channel',
                                 { exhibit_id: exhibit.id, finished: true,
                                   completed: 10, total: 10, errors: [],
                                   updated_at: Time.zone.now, started_at:  Time.zone.now }
  end

  it 'is rendered on the item admin page' do
    expect(page).to have_css('.card.index-status', visible: true)
    within('.card.index-status') do
      expect(page).to have_css('p', text: /Began reindexing a total of \d+ items/)
      expect(page).to have_css('p', text: /Reindexed \d+ of \d+ items/)
    end
  end
end
