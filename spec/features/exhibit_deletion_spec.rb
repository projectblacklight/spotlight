# frozen_string_literal: true

describe 'Deleting an exhibit', type: :feature do
  include ActiveJob::TestHelper

  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }

  it 'removes items associated witht the exhibit', js: true do
    visit spotlight.new_exhibit_resource_path(exhibit)
    click_link 'Upload item'
    attach_file('resources_upload_url', File.join(FIXTURES_PATH, '800x600.png'))
    fill_in 'Title', with: '800x600'

    within '#new_resources_upload' do
      click_button 'Add item'
    end
    expect(page).to have_content 'Object uploaded successfully.'

    visit spotlight.exhibit_dashboard_path(exhibit)
    upload_before_delete = exhibit.resources.last.id
    within '#sidebar' do
      click_link 'General'
    end

    within '.nav-tabs' do
      click_link 'Delete exhibit'
    end

    accept_confirm do
      click_link 'Delete'
    end
    expect(page).to have_content('The exhibit was deleted')

    expect(Spotlight::Exhibit.exists?(exhibit.id)).to be_falsey
    expect(Spotlight::Resources::Upload.exists?(upload_before_delete)).to be_falsey
  end
end
