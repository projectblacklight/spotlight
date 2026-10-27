# frozen_string_literal: true

RSpec.describe 'spotlight/catalog/_edit_default.html.erb', type: :view do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = :title_field
      %w[full_title_tesim spotlight_upload_description_tesim spotlight_upload_attribution_tesim spotlight_upload_date_tesim].each do |field|
        config.add_index_field field, label: "#{field} label"
      end
    end
  end

  let(:document) { stub_model(SolrDocument) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:custom_field) { FactoryBot.create(:custom_field, exhibit:) }

  before do
    view.extend Spotlight::ApplicationHelper
    allow(view).to receive_messages(blacklight_config:, current_exhibit: exhibit)
    allow(view).to receive_messages(document:)
    allow(view).to receive(:can?).and_return(true)
  end

  it 'has a edit tag form' do
    render
    expect(view).to have_received(:can?).at_least(:once)
    expect(rendered).to have_field 'solr_document_exhibit_tag_list'
  end

  it 'does not have special metadata editing fields for non-uploaded resources' do
    render
    expect(view).to have_received(:can?).at_least(:once)
    expect(rendered).to have_no_field 'full_title_tesim label'
    expect(rendered).to have_no_field 'spotlight_upload_description_tesim label'
    expect(rendered).to have_no_field 'spotlight_upload_attribution_tesim label'
    expect(rendered).to have_no_field 'spotlight_upload_date_tesim label'
  end

  it 'has special metadata fields for an uploaded resource' do
    allow(document).to receive_messages(uploaded_resource?: true)
    render
    expect(view).to have_received(:can?).at_least(:once)
    expect(rendered).to have_field 'full_title_tesim label'
    expect(rendered).to have_field 'spotlight_upload_description_tesim label'
    expect(rendered).to have_field 'spotlight_upload_attribution_tesim label'
    expect(rendered).to have_field 'spotlight_upload_date_tesim label'
  end

  it 'has an input for the custom field' do
    custom_field.update(field_type: 'text')

    render

    expect(view).to have_received(:can?).at_least(:once)
    expect(rendered).to have_field 'Some Field', type: 'textarea'
  end

  it 'has an single-line input for a vocab custom field' do
    custom_field.update(field_type: 'vocab')

    render

    expect(view).to have_received(:can?).at_least(:once)
    expect(rendered).to have_field 'Some Field', type: 'text'
  end
end
