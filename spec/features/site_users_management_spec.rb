# frozen_string_literal: true

RSpec.describe 'Site users management', js: true do
  let(:user) { FactoryBot.create(:site_admin) }
  let!(:existing_user) { FactoryBot.create(:exhibit_visitor) }
  let!(:exhibit_admin) { FactoryBot.create(:exhibit_admin) }
  let!(:exhibit_curator) { FactoryBot.create(:exhibit_curator) }

  before do
    login_as(user)
    visit spotlight.admin_users_path
  end

  it 'displays the current admin users' do
    expect(page).to have_css('td', text: user.email)
  end

  describe 'copy email addresses' do
    it 'displays only email addresses of users w/ roles' do
      expect(page).to have_css('div#admins_curators', text: user.email)
      expect(page).to have_css('div#admins_curators', text: exhibit_admin.email)
      expect(page).to have_css('div#admins_curators', text: exhibit_curator.email)
      expect(page).to have_no_css('div#admins_curators', text: existing_user.email)
      expect(page).to have_css('button.copy-email-addresses')
    end
  end

  it 'allows non-existing users to be invited' do
    click_link 'Add new site admin'

    fill_in 'user_email', with: 'not-an-existing-user@example.com'

    click_button 'Add role'

    expect(page).to have_content('not-an-existing-user@example.com site admin pending')
  end

  it 'allows the admin to remove the admin role from the user' do
    click_link 'Add new site admin'

    fill_in 'user_email', with: 'not-an-admin@example.com'

    click_button 'Add role'

    expect(page).to have_css('td', text: 'not-an-admin@example.com')

    expect(page).to have_css('a', text: 'Remove site admin role', count: 2)
    page.accept_confirm('Are you sure you want to remove the site admin role for not-an-admin@example.com?') do
      within(all('table tbody tr:not([data-edit-for])').last) do
        click_link 'Remove site admin role'
      end
    end

    expect(page).to have_content 'User removed from site adminstrator role'
    expect(page).to have_css('a', text: 'Remove site admin role', count: 0)
  end

  it 'allows the admin to remove all exhibit roles from a user' do
    expect(page).to have_css('td.user-exhibit-roles a.btn', text: 'Remove all exhibit roles', count: 2)
    page.accept_confirm("Are you sure you want to remove all exhibit roles for #{exhibit_curator.email}") do
      within(find('td.user-emails', text: exhibit_curator.email).sibling('td.user-exhibit-roles')) do
        click_link 'Remove all exhibit roles'
      end
    end

    expect(page).to have_content 'Removed all exhibit roles for user'
    expect(page).to have_css('td.user-exhibit-roles a.btn', text: 'Remove all exhibit roles', count: 1)
  end

  it 'sends an invitation email to users who do not exist' do
    click_link 'Add new site admin'

    fill_in 'user_email', with: 'a-user-that-did-not-exist@example.com'

    expect do
      click_button 'Add role'
      expect(page).to have_content('Added user as an adminstrator')
    end.to change { Devise::Mailer.deliveries.count }.by(1)
    expect(User.where(email: 'a-user-that-did-not-exist@example.com').first.invitation_sent_at).to be_present
  end

  it 'does not provide a button for users to remove their own adminstrator privs' do
    click_link 'Add new site admin'

    expect(page).to have_css('td', text: user.email)
    # There is just our admin user so no button
    expect(page).to have_css('a', text: 'Remove from admin role', count: 0)
  end
end
