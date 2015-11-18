require 'spec_helper'

describe 'About page', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:about_page1) { FactoryGirl.create(:about_page, title: 'First Page', exhibit: exhibit) }
  let!(:about_page2) { FactoryGirl.create(:about_page, title: 'Second Page', exhibit: exhibit) }
  let(:unpublished_page) { FactoryGirl.create(:about_page, title: 'Unpublished Page', published: false, exhibit: exhibit) }
  describe 'sidebar' do
    it 'displays' do
      visit spotlight.exhibit_about_page_path(about_page1.exhibit, about_page1)
      # the sidebar should display
      within('#sidebar') do
        # within the sidebar navigation
        within('ul.sidenav') do
          # the current page should be active
          expect(page).to have_css('li.active', text: about_page1.title)
          # the other page should be linked
          expect(page).to have_css('li a', text: about_page2.title)
        end
      end
    end
  end
  describe 'page options' do
    before { login_as exhibit_curator }
    describe 'publish' do
      it 'is updatable from the edit page' do
        expect(unpublished_page).not_to be_published

        visit spotlight.edit_exhibit_about_page_path(unpublished_page.exhibit, unpublished_page)
        expect(find('#about_page_published')).not_to be_checked

        check 'Publish'
        click_button 'Save changes'

        expect(unpublished_page.reload).to be_published

        visit spotlight.edit_exhibit_about_page_path(unpublished_page.exhibit, unpublished_page)
        expect(find('#about_page_published')).to be_checked
      end
    end
  end
end
