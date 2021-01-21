# frozen_string_literal: true

describe 'Browse Group Adminstration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  before { login_as exhibit_curator }

  it 'is able to create new groups' do
    visit spotlight.exhibit_searches_path(exhibit, anchor: 'browse-groups')

    add_new_via_button('My New Group')

    expect(page).to have_content 'The group was created.'
    expect(page).to have_css('li.dd-item')
    expect(page).to have_css('h4', text: 'My New Group')
  end
end
