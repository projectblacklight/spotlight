# frozen_string_literal: true

describe 'Add a contact to an exhibit', type: :feature do
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:about_page) { FactoryBot.create(:about_page, exhibit: exhibit) }
  let!(:contact) { FactoryBot.create(:contact, name: 'Marcus Aurelius', exhibit: exhibit) }
  before { login_as curator }

  it 'displays a newly added contact in the sidebar' do
    visit spotlight.exhibit_about_pages_path(exhibit)

    within '.contacts_admin' do
      click_link 'Edit'
    end

    click_button 'Save'
    expect(page).to have_content 'The contact was successfully updated.'
  end
end
