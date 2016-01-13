require 'spec_helper'

describe 'Roles Admin', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before do
    login_as exhibit_admin

    visit spotlight.exhibit_dashboard_path(exhibit)
    click_link 'Users'
  end

  it 'informs the admin that a user they are trying to add does not yet exist' do
    expect(page).to have_css('.help-block[data-behavior="no-user-note"]', visible: false)
    expect(page).not_to have_css('input[disabled]')

    click_link 'Add a new user'
    fill_in 'User key', with: 'user@example.com'

    expect(page).to have_css('.help-block[data-behavior="no-user-note"]', visible: true)
    expect(page).to have_link('invite', visible: true)
    expect(page).to have_css('input[disabled]')
  end

  it 'has the appropriate status message when an existing user is added' do
    second_user = FactoryGirl.create(:site_admin)

    click_link 'Add a new user'
    fill_in 'User key', with: second_user.email

    click_button 'Save changes'

    expect(page).to have_css('.alert-info', text: 'User has been updated.')
    expect(page).to have_css('.table.users td', text: second_user.email)
  end

  it 'persists invited users to the exhibits user list' do
    expect(page).not_to have_css('.label-warning pending-label', text: 'pending', visible: true)

    click_link 'Add a new user'
    fill_in 'User key', with: 'user@example.com'
    click_link 'invite'

    within('tr.invite-pending') do
      expect(page).to have_css('td', text: 'user@example.com')
      expect(page).to have_css('.label-warning.pending-label', text: 'pending', visible: true)
    end
  end
end
