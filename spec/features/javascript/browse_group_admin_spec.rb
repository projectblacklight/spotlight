# frozen_string_literal: true

describe 'Browse Group Adminstration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let!(:group1) do
    FactoryBot.create(
      :group,
      title: 'Good group 1',
      exhibit:
    )
  end

  before { login_as exhibit_curator }

  it 'is able to create new groups' do
    visit spotlight.exhibit_searches_path(exhibit, anchor: 'browse-groups')

    add_new_via_button('My New Group')

    expect(page).to have_content 'The browse group was created.'
    expect(page).to have_css('li.dd-item')
    expect(page).to have_css('h4', text: 'My New Group')
  end

  it 'updates the page titles' do
    visit spotlight.exhibit_searches_path(exhibit, anchor: 'browse-groups')

    within("[data-id='#{group1.id}']") do
      within('h4') do
        expect(page).to have_content('Good group 1')
        expect(page).to have_css('.title-field', visible: false)
        click_link('Good group 1')
        expect(page).to have_css('.title-field', visible: true)
        find('.title-field').set('New good group 1')
      end
    end
    click_button('Save changes')
    within("[data-id='#{group1.id}']") do
      within('h4') do
        expect(page).to have_content('New good group 1')
      end
    end
  end
end
