require 'spec_helper'

describe 'Editing metadata fields', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as(admin) }

  it 'works' do
    visit spotlight.edit_exhibit_metadata_configuration_path exhibit

    expect(page).to have_content 'Display and Order Metadata Fields'

    check :blacklight_configuration_index_fields_language_ssm_show
    check :blacklight_configuration_index_fields_abstract_tesim_show
    uncheck :blacklight_configuration_index_fields_note_mapuse_tesim_show

    uncheck :blacklight_configuration_index_fields_abstract_tesim_list
    check :blacklight_configuration_index_fields_language_ssm_list
    check :blacklight_configuration_index_fields_note_mapuse_tesim_list

    click_on 'Save changes'

    expect(exhibit.reload.blacklight_config.index_fields.select { |_k, x| x.list }).to include 'language_ssm', 'note_mapuse_tesim'
    expect(exhibit.blacklight_config.index_fields.select { |_k, x| x.list }).to_not include 'abstract_tesim'
    expect(exhibit.blacklight_config.show_fields.select { |_k, x| x.show }).to include 'language_ssm', 'abstract_tesim'
    expect(exhibit.blacklight_config.show_fields.select { |_k, x| x.show }).to_not include 'note_mapuse_tesim'
  end

  it 'has in-place editing of labels', js: true do
    visit spotlight.edit_exhibit_metadata_configuration_path exhibit
    check :blacklight_configuration_index_fields_language_ssm_show
    check :blacklight_configuration_index_fields_language_ssm_list

    click_on 'Language'

    expect(page).to have_field :blacklight_configuration_index_fields_language_ssm_label, visible: true
    fill_in :blacklight_configuration_index_fields_language_ssm_label, with: 'Language of Origin'

    click_on 'Save changes'
    expect(exhibit.reload.blacklight_config.index_fields['language_ssm'].label).to eq 'Language of Origin'
  end

  it 'has breadcrumbs' do
    visit spotlight.edit_exhibit_metadata_configuration_path exhibit

    expect(page).to have_breadcrumbs 'Home', 'Configuration', 'Metadata'
  end
end
