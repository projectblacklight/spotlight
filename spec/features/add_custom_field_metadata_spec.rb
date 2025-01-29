# frozen_string_literal: true

RSpec.describe 'Adding custom metadata field data', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }
  let(:custom_field) { FactoryBot.create(:custom_field, exhibit:) }
  let(:config) { exhibit.blacklight_configuration }

  before do
    login_as(admin)
    config.index_fields[custom_field.field] = { enabled: true, show: true, 'label' => 'Some Field' }
    config.save!
  end

  it 'allows admins to add metadata to a document' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

    expect(page).to have_link 'Edit'

    click_on 'Edit'

    fill_in 'Some Field', with: 'My new custom field value'

    click_on 'Save changes'

    expect(SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).data).to include 'some-field' => 'My new custom field value'
    sleep(1) # The data isn't commited to solr immediately.

    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')
    expect(page).to have_content 'Some Field'
    expect(page).to have_content 'My new custom field value'
  end

  context 'when given a read-only field' do
    let(:custom_field) { FactoryBot.create(:custom_field, exhibit:, readonly_field: true) }

    it 'can not be edited' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

      expect(page).to have_link 'Edit'

      click_on 'Edit'

      expect(page).to have_selector 'textarea[readonly]'
    end
  end

  context 'with a multivalued field', js: true do
    let(:custom_field) { FactoryBot.create(:custom_field, exhibit:, is_multiple: true) }

    it 'can add multiple values' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

      expect(page).to have_link 'Edit'

      click_on 'Edit'
      fill_in 'Some Field', with: 'value 1'
      click_on 'Add another'
      fill_in 'solr_document_sidecar_data_some-field_2', with: 'value 2'

      click_on 'Save changes'
      sleep 1 # The data isn't committed to solr immediately.

      expect(SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).data).to include 'some-field' => ['value 1', 'value 2']
    end
  end

  it 'has a public toggle' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

    expect(page).to have_no_selector '.blacklight-private'

    click_on 'Edit'

    uncheck 'Public'

    click_on 'Save changes'

    expect(page).to have_selector '.blacklight-private'

    click_on 'Edit'

    check 'Public'

    click_on 'Save changes'

    expect(page).to have_no_selector '.blacklight-private'
  end
end
