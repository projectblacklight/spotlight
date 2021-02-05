# frozen_string_literal: true

describe 'Bulk actions' do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as curator
    d = SolrDocument.new(id: 'dq287tq6352')
    d.make_private! exhibit
    d.reindex
    Blacklight.default_index.connection.commit
  end

  after do
    d = SolrDocument.new(id: 'dq287tq6352')
    d.make_public! exhibit
    d.reindex
    Blacklight.default_index.connection.commit
  end

  it 'setting item visibility', js: true do
    visit spotlight.search_exhibit_catalog_path(exhibit, { q: 'dq287tq6352' })

    click_button 'Bulk actions'
    click_link 'Change item visibility'
    expect(page).to have_css 'h4', text: 'Change item visibility', visible: true
    choose 'Private'
    accept_confirm 'Are you sure?' do
      click_button 'Change'
    end
    expect(page).to have_css '.alert', text: 'Visibility of 1 item is being updated.'
    expect(SolrDocument.new(id: 'dq287tq6352').private?(exhibit)).to be true
  end
end
