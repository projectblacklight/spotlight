describe 'User Administration', type: :feature do
  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as user }
  describe 'index' do
    it 'shows the users for the exhibit' do
      visit spotlight.exhibit_roles_path(exhibit)
      exhibit.roles.each do |role|
        expect(page).to have_css('td', text: role.user.email)
        expect(page).to have_css('td', text: role.role.humanize)
      end
    end

    it 'invites new users to the exhibit', js: true do
      visit spotlight.exhibit_roles_path(exhibit)

      click_link 'Add a new user'

      fill_in 'User key', with: 'a-user-being-invited@example.com'

      expect do
        click_button 'Save changes'
      end.to change { Devise::Mailer.deliveries.count }.by(1)
      expect(User.where(email: 'a-user-being-invited@example.com').first.invitation_sent_at).to be_present

      expect(page).to have_css('.alert-info', text: 'User has been updated.', visible: true)
    end
  end
end
