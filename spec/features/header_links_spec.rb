# frozen_string_literal: true

RSpec.describe 'header links', type: :feature do
  context 'when not signed in' do
    it 'shows sign in' do
      visit main_app.root_path

      expect(page).to have_link('Sign in', href: '/users/sign_in')
    end
  end

  context 'when signed in' do
    let(:user) { FactoryBot.create(:site_admin) }

    it 'shows user util links for admin user' do
      login_as user

      visit main_app.root_path

      expect(page).to have_selector '#user-util-collapse', text: 'Site administration'
      expect(page).to have_selector '#user-util-collapse', text: 'Create new exhibit'
      expect(page).to have_selector '#user-util-collapse', text: 'Change Password'
      expect(page).to have_selector '#user-util-collapse', text: 'Sign out'
    end
  end
end
