describe 'Adding custom metadata field data', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:custom_field) { FactoryBot.create(:custom_field, exhibit: exhibit) }
  let(:config) { exhibit.blacklight_configuration }
  before do
    login_as(admin)
    config.index_fields[custom_field.field] = { enabled: true, show: true, 'label' => 'Some Field' }
    config.save!
  end

  it 'works' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

    expect(page).to have_link 'Edit'

    click_on 'Edit'

    fill_in 'Some Field', with: 'My new custom field value'

    click_on 'Save changes'

    expect(::SolrDocument.new(id: 'dq287tq6352').sidecar(exhibit).data).to include 'field_name_tesim' => 'My new custom field value'
    sleep(1) # The data isn't commited to solr immediately.

    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')
    expect(page).to have_content 'Some Field'
    expect(page).to have_content 'My new custom field value'
  end

  context 'when given a read-only field' do
    let(:custom_field) { FactoryBot.create(:custom_field, exhibit: exhibit, readonly_field: true) }
    it 'can not be edited' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

      expect(page).to have_link 'Edit'

      click_on 'Edit'

      expect(page).to have_selector 'textarea[readonly]'
    end
  end

  it 'has a public toggle' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

    expect(page).not_to have_selector '.blacklight-private'

    click_on 'Edit'

    uncheck 'Public'

    click_on 'Save changes'

    expect(page).to have_selector '.blacklight-private'

    click_on 'Edit'

    check 'Public'

    click_on 'Save changes'

    expect(page).not_to have_selector '.blacklight-private'
  end
end
