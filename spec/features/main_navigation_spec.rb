# frozen_string_literal: true

describe 'Main navigation labels are settable', type: :feature do
  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:about) { FactoryBot.create(:about_page, exhibit:, published: true) }

  before do
    about_nav = exhibit.main_navigations.about
    about_nav.label = 'New About Label'
    about_nav.save
    browse_nav = exhibit.main_navigations.browse
    browse_nav.label = 'New Browse Label'
    browse_nav.save
    search = exhibit.searches.first
    search.published = true
    search.save
    exhibit.reload
  end

  it 'has the configured about and browse navigation labels' do
    visit spotlight.exhibit_path(exhibit)
    expect(page).to have_css('.navbar-nav li', text: 'New About Label')
    expect(page).to have_css('.navbar-nav li', text: 'New Browse Label')
  end

  it 'has the configured about page label in the sidebar' do
    visit spotlight.exhibit_about_page_path(exhibit, about)
    expect(page).to have_css('#sidebar h2', text: 'New About Label')
  end

  it 'has the configured about page label visible in the breadcrumb' do
    visit spotlight.exhibit_about_page_path(exhibit, about)
    expect(page).to have_css('.breadcrumb li', text: 'New About Label')
  end

  it 'has the configured browse page label visible in the breadcrumb of the browse index page' do
    visit spotlight.exhibit_browse_index_path(exhibit, exhibit.searches.first)
    expect(page).to have_content('New Browse Label')
    expect(page).to have_css('.breadcrumb li', text: 'New Browse Label')
  end

  it 'has the configured browse page label visible in the breadcrumb of the browse show page' do
    visit spotlight.exhibit_browse_path(exhibit, exhibit.searches.first)
    expect(page).to have_content('New Browse Label')
    expect(page).to have_css('.breadcrumb li', text: 'New Browse Label')
  end

  it 'does not display any main navigation menu items that are configured to not display' do
    about_nav = exhibit.main_navigations.about
    about_nav.display = false
    about_nav.save
    visit spotlight.exhibit_path(exhibit)
    expect(page).to have_no_css('.navbar-nav li', text: 'New About Label')
    about_nav = exhibit.main_navigations.about
    about_nav.display = true
    about_nav.save
  end

  describe 'Restore default button functionality', js: true do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

    before { login_as user }

    it 'is present when the navigation label is not the default value' do
      visit spotlight.edit_exhibit_appearance_path(exhibit)

      click_link 'Main menu'

      within '.main_navigation_admin' do
        within all('li').first do
          expect(page).to have_no_css('button.restore-default', visible: true)
        end

        within all('li').last do
          expect(page).to have_css('button.restore-default', visible: true)
        end
      end
    end

    context 'when the navigation label is not the default value' do
      it 'restores the default value' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)

        click_link 'Main menu'

        within '.main_navigation_admin' do
          within all('li').last do
            expect(page).to have_css('a', text: 'New About Label')
            click_button 'Restore default'
            expect(page).to have_css('a', text: 'About')
          end
        end
      end
    end
  end
end
