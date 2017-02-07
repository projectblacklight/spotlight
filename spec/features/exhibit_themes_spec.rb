describe 'Update the site theme', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

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

    expect(field_labeled('Modern')).to be_checked
    expect(page).to have_xpath('//link[contains(@href, "/stylesheets/application_modern.css")]', visible: false)
  end
end
