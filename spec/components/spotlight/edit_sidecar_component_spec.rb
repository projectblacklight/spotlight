# frozen_string_literal: true

RSpec.describe Spotlight::EditSidecarComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(form: f, document:, exhibit:) }
  let(:f) { BootstrapForm::FormBuilder.new('solr_document', document, vc_test_controller.view_context, builder: BootstrapForm::FormBuilder) }
  let(:document) { SolrDocument.new(id: 'abc123') }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:custom_field) { FactoryBot.create(:custom_field, exhibit:, field_type: 'text') }

  before do
    allow(vc_test_controller).to receive_messages(blacklight_config: Blacklight::Configuration.new)
    document.sidecar(exhibit).update(data: { custom_field.slug => 'custom value' })
  end

  it 'renders the custom field with its stored value' do
    expect(rendered).to have_field 'Some Field', type: 'textarea', with: 'custom value'
  end

  it 'does not render upload fields for non-uploaded resources' do
    expect(rendered).to have_no_css "[name^='solr_document[sidecar][data][configured_fields]']"
  end

  context 'with a custom field that is not configured to display' do
    before do
      allow_any_instance_of(Spotlight::CustomField).to receive(:configured_to_display?).and_return(false) # rubocop:disable RSpec/AnyInstance
    end

    it 'warns that the field is hidden' do
      expect(rendered).to have_css 'p.bg-warning', text: 'This field is currently hidden on all pages'
      expect(rendered).to have_link 'Metadata', href: "/spotlight/#{exhibit.slug}/metadata_configuration/edit"
    end
  end

  context 'with an uploaded resource' do
    before do
      allow(document).to receive(:uploaded_resource?).and_return(true)
      document.sidecar(exhibit).update(data: { 'configured_fields' => { 'spotlight_upload_description_tesim' => 'A description' } })
    end

    it 'renders the upload fields with their stored values' do
      expect(rendered).to have_css "textarea[name='solr_document[sidecar][data][configured_fields][spotlight_upload_description_tesim]']",
                                   text: 'A description'
    end
  end
end
