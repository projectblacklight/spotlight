require 'spec_helper'

describe 'Item Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as curator }

  before do
    allow_any_instance_of(::SolrDocument).to receive_messages(reindex: true)
  end

  describe 'admin' do
    it "does not have a 'Save this search' button" do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      expect(page).not_to have_css('button', text: 'Save this search')
    end
    it 'has catalog items' do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      expect(page).to have_css('h1 small', text: 'Items')
      expect(page).to have_css('table#documents')
      expect(page).to have_css('.pagination')

      item = first('tr[itemscope]')
      expect(item).to have_link 'View'
      expect(item).to have_link 'Edit'
    end

    it 'has a public/private toggle' do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      item = first('tr[itemscope]')
      expect(item).to have_button 'Make Private'
      item.click_button 'Make Private'

      item = first('tr[itemscope]')
      expect(item).to have_button 'Make Public'
      item.click_button 'Make Public'
    end

    it "toggles the 'blacklight-private' label", js: true do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      # The label should be toggled when the checkbox is clicked
      expect(page).to_not have_css('tr.blacklight-private')
      within 'tr[itemscope]:first-child' do
        find("input.toggle_visibility[type='checkbox']").click
      end
      expect(page).to have_css('tr.blacklight-private')

      # The label should show up on page load
      expect(page).to have_css('tr.blacklight-private')
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      within 'tr[itemscope]:first-child' do
        find("input.toggle_visibility[type='checkbox']").click
      end
      expect(page).to_not have_css('tr.blacklight-private')
    end
  end
end
