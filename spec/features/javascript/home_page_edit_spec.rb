# frozen_string_literal: true

feature 'Editing the Home Page', js: true, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as admin }

  it 'does not have a search results widget' do
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    click_add_widget
    expect(page).to have_css("[data-type='solr_documents']", visible: true)
    expect(page).not_to have_css("[data-type='search_results']", visible: true)
  end

  it 'correctly saves a list widget' do
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    click_add_widget
    expect(page).to have_css('button.st-block-controls__button')

    find("button[data-type='list']").click
    expect(page).to have_css('ul.st-list-block__list')
    expect(page).to have_css('li.st-list-block__item')
    expect(page).to have_css('*[contenteditable=true]')
    expect(page).to have_css('div.st-list-block__editor[contenteditable=true]', count: 1)

    first_element = page.all('div.st-list-block__editor[contenteditable=true]').first
    first_element.set('one')

    click_button 'Save changes'
    expect(page).to have_css('div.st__content-block--list ul li', count: 1)
    expect(page).to have_css('div.st__content-block--list ul li', text: 'on')
  end
end
