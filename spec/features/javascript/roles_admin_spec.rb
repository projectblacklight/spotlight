describe 'Roles Admin', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before do
    login_as exhibit_admin

    visit spotlight.exhibit_dashboard_path(exhibit)
    click_link 'Users'
  end

  it 'has the appropriate status message when an existing user is added' do
    second_user = FactoryBot.create(:site_admin)

    click_link 'Add a new user'
    fill_in 'User key', with: second_user.email

    click_button 'Save changes'

    expect(page).to have_css('.alert-info', text: 'User has been updated.')
    expect(page).to have_css('.table.users td', text: second_user.email)
  end

  it 'persists invited users to the exhibits user list' do
    expect(page).not_to have_css('.badge-warning pending-label', text: 'pending', visible: true)

    click_link 'Add a new user'
    fill_in 'User key', with: 'user@example.com'
    click_button 'Save changes'

    within('tr.invite-pending') do
      expect(page).to have_css('td', text: 'user@example.com')
      expect(page).to have_css('.badge-warning.pending-label', text: 'pending', visible: true)
    end
  end
end
