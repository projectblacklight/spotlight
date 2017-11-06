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
  end
end
