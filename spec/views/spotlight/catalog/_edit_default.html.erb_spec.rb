require 'spec_helper'

describe "spotlight/catalog/_edit_default.html.erb", :type => :view do
  let(:blacklight_config) {
    Blacklight::Configuration.new do |config|
      config.index.title_field = :title_field
    end
  }

  let(:document) { stub_model(::SolrDocument) }

  let(:exhibit) { stub_model(Spotlight::Exhibit) }

  before do
    allow(exhibit).to receive_messages(blacklight_config: blacklight_config)

    allow(view).to receive_messages(exhibit_tags_path: "autocomplete-path.json")
    allow(view).to receive_messages(blacklight_config: blacklight_config)
    allow(view).to receive_messages(current_exhibit: exhibit)
    allow(view).to receive_messages(document: document)
    allow(view).to receive(:can?).and_return(true)
  end

  it "should have a edit tag form" do
    render
    expect(rendered).to have_field 'solr_document_exhibit_tag_list'
    expect(rendered).to have_selector '#solr_document_exhibit_tag_list[@data-autocomplete_url="autocomplete-path.json"]'
  end
  it 'should not have special metadata editing fields for non-uploaded resources' do
    render
    expect(rendered).to_not have_field 'Title'
    expect(rendered).to_not have_field 'Description'
    expect(rendered).to_not have_field 'Attribution'
    expect(rendered).to_not have_field 'Date'
  end
  it 'should have special metadata fields for an uploaded resource' do
    allow(document).to receive_messages(:uploaded_resource? => true)
    render
    expect(rendered).to have_field 'Title'
    expect(rendered).to have_field 'Description'
    expect(rendered).to have_field 'Attribution'
    expect(rendered).to have_field 'Date'
  end
end