describe 'Update the site theme', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }

  it 'updates the exhibit theme' do
    visit spotlight.edit_exhibit_appearance_path(exhibit)

    expect(page).to have_content('Visual theme')
    choose 'Modern'

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Exhibit masthead'

    expect(page).to have_checked_field 'Modern'
    expect(page).to have_xpath('//link[contains(@href, "/assets/application_modern")]', visible: false)
  end
end
