require 'spec_helper'

describe 'spotlight/catalog/_edit_default.html.erb', type: :view do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = :title_field
    end
  end

  let(:document) { stub_model(::SolrDocument) }

  let(:exhibit) { stub_model(Spotlight::Exhibit) }

  before do
    allow(exhibit).to receive_messages(blacklight_config: blacklight_config)

    allow(view).to receive(:uploaded_field_label) do |config|
      "#{config.field_name} label"
    end
    allow(view).to receive_messages(exhibit_tags_path: 'autocomplete-path.json')
    allow(view).to receive_messages(blacklight_config: blacklight_config)
    allow(view).to receive_messages(current_exhibit: exhibit)
    allow(view).to receive_messages(document: document)
    allow(view).to receive(:can?).and_return(true)
  end

  it 'has a edit tag form' do
    render
    expect(rendered).to have_field 'solr_document_exhibit_tag_list'
    expect(rendered).to have_selector '#solr_document_exhibit_tag_list[@data-autocomplete_url="autocomplete-path.json"]'
  end
  it 'does not have special metadata editing fields for non-uploaded resources' do
    render
    expect(rendered).to_not have_field 'title_field label'
    expect(rendered).to_not have_field 'spotlight_upload_description_tesim label'
    expect(rendered).to_not have_field 'spotlight_upload_attribution_tesim label'
    expect(rendered).to_not have_field 'spotlight_upload_date_tesim label'
  end
  it 'has special metadata fields for an uploaded resource' do
    allow(document).to receive_messages(uploaded_resource?: true)
    render
    expect(rendered).to have_field 'title_field label'
    expect(rendered).to have_field 'spotlight_upload_description_tesim label'
    expect(rendered).to have_field 'spotlight_upload_attribution_tesim label'
    expect(rendered).to have_field 'spotlight_upload_date_tesim label'
  end
end
