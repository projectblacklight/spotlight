# frozen_string_literal: true

describe 'Bulk actions', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as curator
    d = SolrDocument.new(id: 'dq287tq6352')
    exhibit.tag(d.sidecar(exhibit), with: ['foo'], on: :tags)
    d.make_private! exhibit
    d.reindex
    Blacklight.default_index.connection.commit
  end

  after do
    d = SolrDocument.new(id: 'dq287tq6352')
    exhibit.tag(d.sidecar(exhibit), with: [], on: :tags)
    exhibit.owned_tags.destroy_all
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

  it 'adding tags', js: true do
    visit spotlight.search_exhibit_catalog_path(exhibit, { q: 'dq287tq6352' })

    click_button 'Bulk actions'
    click_link 'Add tags'
    expect(page).to have_css 'h4', text: 'Add tags', visible: true
    within '#add-tags-modal' do
      find('[data-autocomplete-fetched="true"]', visible: false)
      find('.tt-input').set('good,stuff')
    end
    accept_confirm 'Are you sure?' do
      click_button 'Add'
    end
    expect(page).to have_css '.alert', text: 'Tags are being added for 1 item.'
    expect(SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).all_tags_list).to include('foo', 'good', 'stuff')
  end

  it 'removing tags', js: true do
    visit spotlight.search_exhibit_catalog_path(exhibit, { q: 'dq287tq6352' })

    click_button 'Bulk actions'
    click_link 'Remove tags'
    expect(page).to have_css 'h4', text: 'Remove tags', visible: true
    within '#remove-tags-modal' do
      find('[data-autocomplete-fetched="true"]', visible: false)
      find('.tt-input').set('foo')
    end
    accept_confirm 'Are you sure?' do
      click_button 'Remove'
    end
    expect(page).to have_css '.alert', text: 'Tags are being removed for 1 item.'
    expect(SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).all_tags_list).to eq []
  end
end
