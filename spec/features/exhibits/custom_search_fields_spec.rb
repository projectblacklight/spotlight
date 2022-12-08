# frozen_string_literal: true

describe 'Adding custom search fields', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before do
    login_as(admin)
  end

  it 'allows admins to define a new custom search field' do
    # Add

    visit spotlight.edit_exhibit_search_configuration_path exhibit
    click_on 'Add new field'
    fill_in 'Label', with: 'My new custom field'
    fill_in 'Slug', with: 'Foo'
    fill_in 'Solr specification', with: 'title^50'

    click_on 'Save'

    expect(page).to have_content 'The custom search field was created.'
    within '#exhibit-specific-fields' do
      expect(page).to have_selector '.field-label', text: 'My new custom field'
      expect(page).to have_selector '.field-description', text: 'title^50'
      # Edit
      click_link 'Edit'
    end

    # on the edit form
    expect(find_field('Label').value).to eq 'My new custom field'
    expect(find_field('Slug').value).to eq 'Foo'
    expect(find_field('Solr specification').value).to eq 'title^50'
    fill_in 'Solr specification', with: 'title^50 description^26'

    click_button 'Save changes'

    expect(page).to have_content 'The custom search field was successfully updated.'

    within '#exhibit-specific-fields' do
      expect(page).to have_selector '.field-label', text: 'My new custom field'
      expect(page).to have_selector '.field-description', text: 'title^50 description^26'
      # Destroy
      click_link 'Delete'
    end

    expect(page).to have_content 'The custom search field was deleted.'
  end

  it 'has breadcrumbs' do
    visit spotlight.edit_exhibit_search_configuration_path exhibit
    click_on 'Add new field'
    expect(page).to have_breadcrumbs 'Home', 'Configuration', 'Search', 'Add new field'
  end
end
