require 'spec_helper'

feature 'Browse pages' do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  context 'a browse page' do
    let!(:search) { FactoryGirl.create(:search, title: 'Some Saved Search', exhibit: exhibit, published: true) }
    context 'with the standard exhibit masthead' do
      it 'includes the search title and resource count in the body' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        within '#main-container' do
          expect(page).to have_selector 'h1', text: 'Some Saved Search'
        end

        expect(page).not_to have_selector '.masthead .h1', text: 'Some Saved Search'
      end

      it 'shows the search bar' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.search-query-form'
      end

      it 'has breadcrumbs' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.breadcrumbs-container'
      end
    end

    context 'with a custom masthead' do
      let(:masthead) { FactoryGirl.create(:masthead, display: true) }

      before do
        search.masthead = masthead
        search.save
      end

      it 'has a contextual masthead with the title and resource count' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.masthead .h1', text: 'Some Saved Search'

        within '#main-container' do
          expect(page).not_to have_selector 'h1', text: 'Some Saved Search'
        end

        expect(page).to have_selector '.masthead small.item-count', text: /\d+ items/
      end

      it 'does not show the search bar' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).not_to have_selector '.search-query-form'
      end

      it 'does not have breadcrumbs' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).not_to have_selector '.breadcrumbs-container'
      end
    end
  end
end
