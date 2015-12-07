require 'spec_helper'

feature 'Search contexts' do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:feature_page) do
    FactoryGirl.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit: exhibit
    )
  end
  before { login_as exhibit_curator }

  scenario 'should add context breadcrumbs back to the home page when navigating to an item from the home page', js: true do
    exhibit.home_page.content = [
      {
        type: 'solr_documents',
        data: {
          item: {
            dq287tq6352: {
              id: 'dq287tq6352',
              display: 'true'
            }
          }
        }
      }].to_json
    exhibit.home_page.save

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.items-block') do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).not_to have_css('.title')
    end

    find('.thumbnail a').trigger('click')

    expect(page).to have_selector '.breadcrumb a', text: 'Home'
  end

  scenario 'should add context breadcrumb back to the feature page when navigating to an item from a feature page', js: true do
    feature_page.content = [
      {
        type: 'solr_documents',
        data: {
          item: {
            dq287tq6352: {
              id: 'dq287tq6352',
              display: 'true'
            }
          }
        }
      }].to_json
    feature_page.save

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.items-block') do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).not_to have_css('.title')
    end

    find('.thumbnail a').trigger('click')

    expect(page).to have_selector '.breadcrumb a', text: 'Home'
    expect(page).to have_link 'FeaturePage1', href: spotlight.exhibit_feature_page_path(exhibit, feature_page)
  end

  context 'from a browse page' do
    let!(:search) { FactoryGirl.create(:search, title: 'Some Saved Search', exhibit: exhibit, published: true) }

    scenario 'should add context breadcrumbs back to the browse page when navigating to an item', js: true do
      visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
      click_link 'Browse'
      click_link 'Some Saved Search'
      click_link 'A MAP of AMERICA from the latest and best Observations'
      expect(page).to have_link 'Home'
      expect(page).to have_link 'Browse'
      expect(page).to have_link 'Some Saved Search', href: spotlight.exhibit_browse_path(exhibit, search)
    end
  end
end
