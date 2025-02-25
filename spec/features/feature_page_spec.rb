# frozen_string_literal: true

RSpec.describe 'Feature page', type: :feature, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  describe 'viewing the page' do
    let!(:feature_page) do
      FactoryBot.create(:feature_page, title: 'Parent Page', exhibit:)
    end

    it 'has <meta> tags' do
      visit spotlight.exhibit_feature_page_path(feature_page.exhibit, feature_page)

      expect(page).to have_css "meta[name='twitter:title'][content='#{feature_page.title}']", visible: false
      expect(page).to have_css "meta[property='og:site_name']", visible: false
      expect(page).to have_css "meta[property='og:type'][content='article']", visible: false
      expect(page).to have_css "meta[property='og:title'][content='#{feature_page.title}']", visible: false
    end
  end

  describe 'sidebar' do
    let!(:parent_feature_page) do
      FactoryBot.create(:feature_page, title: 'Parent Page', exhibit:)
    end
    let!(:child_feature_page) do
      FactoryBot.create(
        :feature_page,
        title: 'Child Page',
        parent_page: parent_feature_page, exhibit:
      )
    end

    describe 'when configured to display' do
      before { parent_feature_page.update display_sidebar: true }

      after { parent_feature_page.update display_sidebar: false }

      it 'is present' do
        visit spotlight.exhibit_feature_page_path(parent_feature_page.exhibit, parent_feature_page)
        # the sidebar should display
        within('#sidebar') do
          # the current page should be the sidebar header
          expect(page).to have_css('li', text: parent_feature_page.title)
          # within the sidebar navigation
          within('ol.sidenav') do
            # there should be a link to the child page
            expect(page).to have_css('li a', text: child_feature_page.title)
          end
        end
      end
    end

    describe 'when configured to not display' do
      before { parent_feature_page.update display_sidebar: false }

      context 'with a child page' do
        it 'is present anyway' do
          visit spotlight.exhibit_feature_page_path(parent_feature_page.exhibit, parent_feature_page)
          expect(page).to have_css('#sidebar')
          expect(page).to have_content(child_feature_page.title)
        end
      end

      context 'with an unpublished child page' do
        before { child_feature_page.update published: false }

        it 'does not be present' do
          visit spotlight.exhibit_feature_page_path(parent_feature_page.exhibit, parent_feature_page)
          expect(page).to have_no_css('#sidebar')
          expect(page).to have_no_content(child_feature_page.title)
        end
      end
    end
  end

  describe 'page options' do
    before { login_as exhibit_curator }

    describe 'publish' do
      let!(:unpublished_page) { FactoryBot.create(:feature_page, published: false, exhibit:) }

      it 'is updatable from the edit page' do
        expect(unpublished_page).not_to be_published

        visit spotlight.edit_exhibit_feature_page_path(unpublished_page.exhibit, unpublished_page)
        expect(find_by_id('feature_page_published')).not_to be_checked

        check 'Publish'
        click_button 'Save changes'

        expect(unpublished_page.reload).to be_published

        visit spotlight.edit_exhibit_feature_page_path(unpublished_page.exhibit, unpublished_page)
        expect(find_by_id('feature_page_published')).to be_checked
      end
    end

    describe 'display_sidebar' do
      let!(:feature_page) { FactoryBot.create(:feature_page, display_sidebar: false, exhibit:) }

      before { feature_page.update display_sidebar: false }

      it 'is updatable from the edit page' do
        expect(feature_page).not_to be_display_sidebar

        visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)
        expect(find_by_id('feature_page_display_sidebar')).not_to be_checked

        check 'Show sidebar'
        click_button 'Save changes'

        expect(feature_page.reload).to be_display_sidebar

        visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)
        expect(find_by_id('feature_page_display_sidebar')).to be_checked
      end
    end
  end

  describe 'page locking' do
    before { login_as exhibit_curator }

    let!(:feature_page) { FactoryBot.create(:feature_page, display_sidebar: false, exhibit:) }

    it 'shows a lock message if someone is currently editing the page' do
      # open the edit page
      visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)

      # and then open the edit page again
      visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)

      expect(page).to have_css '.alert'
      within '.alert' do
        expect(page).to have_content 'This page is currently being edited by ' + exhibit_curator.to_s
      end
    end

    it 'releases the lock when the lock holder cancels edits', js: true do
      # open the edit page
      visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)

      click_on 'Cancel'

      # and then open the edit page again
      visit spotlight.edit_exhibit_feature_page_path(feature_page.exhibit, feature_page)

      expect(page).to have_no_css '.alert'
    end
  end
end
