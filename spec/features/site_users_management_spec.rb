# frozen_string_literal: true

describe 'Site users management', js: true do
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
    click_link 'Add new administrator'

    fill_in 'user_email', with: 'not-an-existing-user@example.com'

    click_button 'Add role'

    expect(page).to have_content('not-an-existing-user@example.com pending')
  end

  it 'allows the admin to remove the admin role from the user' do
    click_link 'Add new administrator'

    fill_in 'user_email', with: 'not-an-admin@example.com'

    click_button 'Add role'

    expect(page).to have_css('td', text: 'not-an-admin@example.com')

    expect(page).to have_css('a', text: 'Remove from admin role', count: 2)
    within(all('table tbody tr:not([data-edit-for])').last) do
      click_link 'Remove from admin role'
    end

    expect(page).to have_content 'User removed from site adminstrator role'
    expect(page).to have_css('a', text: 'Remove from admin role', count: 0)
  end

  it 'sends an invitation email to users who do not exist' do
    click_link 'Add new administrator'

    fill_in 'user_email', with: 'a-user-that-did-not-exist@example.com'

    expect do
      click_button 'Add role'
      sleep 1 # Test fails without this after move to Propshaft.
    end.to change { Devise::Mailer.deliveries.count }.by(1)
    expect(User.where(email: 'a-user-that-did-not-exist@example.com').first.invitation_sent_at).to be_present
  end

  it 'does not provide a button for users to remove their own adminstrator privs' do
    click_link 'Add new administrator'

    expect(page).to have_css('td', text: user.email)
    # There is just our admin user so no button
    expect(page).to have_css('a', text: 'Remove from admin role', count: 0)
  end
end
