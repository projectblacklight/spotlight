# frozen_string_literal: true

RSpec.describe 'Manage exhibit users and roles', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before do
    login_as(admin)
    visit spotlight.exhibit_roles_path(exhibit)
  end

  it 'admins can add a new user' do
    click_on 'Add a new user'
    expect(page).to have_selector('[data-edit-for="new"]')
    fill_in 'User key', with: 'email@myemail.edu'
    click_button 'Save changes'
    expect(page).to have_content 'User has been updated.'
  end

  it 'admins can edit existing roles' do
    find("[data-behavior='edit-user'][data-target='#{admin.id}']").click
    expect(page).to have_selector("[data-edit-for='#{admin.id}']")
  end

  it 'admins can cancel adding a new user' do
    click_on 'Add a new user'
    expect(page).to have_selector('[data-edit-for="new"]')
    click_on 'Cancel'
    expect(page).to have_no_selector('[data-edit-for="new"]')
  end
end
