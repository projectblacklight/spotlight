# frozen_string_literal: true

RSpec.describe Spotlight::UploadFieldFormGroupComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(form: f, config:, value: 'a', inline: true) }
  let(:f) { BootstrapForm::FormBuilder.new('data', nil, vc_test_controller.view_context, layout: :horizontal, label_col: 'col-md-2', control_col: 'col-md-6') }
  let(:config) { Spotlight::UploadFieldConfig.new(field_name: 'x', label: 'X', form_field_type: :text_area, is_multiple: true, component: field_component) }
  let(:field_component) { nil }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    allow(vc_test_controller).to receive_messages(blacklight_config:)
  end

  it 'renders the field with the SidecarFormFieldComponent by default' do
    expect(rendered).to have_css '.form-group.row label.col-md-2', text: 'X'
    expect(rendered).to have_css "textarea[name='data[x][]']", text: 'a'
  end

  context 'when the blacklight config has a label for the solr field' do
    before do
      blacklight_config.add_index_field 'x', label: 'solr x'
    end

    it 'uses that label' do
      expect(rendered).to have_css 'label', text: 'solr x'
    end
  end

  context 'with a configured component' do
    let(:field_component) do
      Class.new(Spotlight::SidecarFormFieldComponent) do
        def self.name = 'CustomUploadFieldComponent'
        def call = tag.div('custom', class: "custom-#{field_id}")
      end
    end

    it 'renders the field with that component' do
      expect(rendered).to have_css '.custom-x', text: 'custom'
    end
  end
end
