# frozen_string_literal: true

RSpec.describe 'Item Administration', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  before do
    login_as curator
    allow_any_instance_of(SolrDocument).to receive_messages(reindex: true)
  end

  describe 'admin' do
    it "does not have a 'Save this search' button" do
      visit spotlight.admin_exhibit_catalog_path(exhibit)
      expect(page).to have_no_css('button', text: 'Save this search')
    end

    it 'has catalog items' do
      visit spotlight.admin_exhibit_catalog_path(exhibit)
      expect(page).to have_css('h1 small', text: 'Items')
      expect(page).to have_css('table#documents')
      expect(page).to have_css('.pagination')
      expect(page).to have_css('.spotlight-admin-thumbnail')

      item = first('tr[itemscope]')
      expect(item).to have_link 'View'
      expect(item).to have_link 'Edit'
    end

    it 'has a public/private toggle' do
      visit spotlight.admin_exhibit_catalog_path(exhibit)
      item = first('tr[itemscope]')
      expect(item).to have_button 'Make private'
      item.click_button 'Make private'

      item = first('tr[itemscope]')
      expect(item).to have_button 'Make public'
      item.click_button 'Make public'
    end

    it "toggles the 'blacklight-private' label", js: true, max_wait_time: 5 do
      visit spotlight.admin_exhibit_catalog_path(exhibit)
      # The label should be toggled when the checkbox is clicked
      expect(page).to have_no_css('tr.blacklight-private')
      within 'tr[itemscope]:first-child' do
        find("input.toggle-visibility[type='checkbox']").click
      end
      expect(page).to have_css('tr.blacklight-private')

      # The label should show up on page load
      expect(page).to have_css('tr.blacklight-private')
      visit spotlight.admin_exhibit_catalog_path(exhibit)
      within 'tr[itemscope]:first-child' do
        find("input.toggle-visibility[type='checkbox']").click
      end
      expect(page).to have_no_css('tr.blacklight-private')
    end
  end
end
