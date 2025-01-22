# frozen_string_literal: true

RSpec.describe 'spotlight/metadata_configurations/_metadata_field', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:field) { Blacklight::Configuration::Field.new label: 'Some label', immutable: OpenStruct.new(another_view_type: false) }
  let(:p) { 'spotlight/metadata_configurations/metadata_field' }
  let(:f) do
    form_helper = nil
    controller.view_context.bootstrap_form_for('z', url: '/update') do |f|
      form_helper = f
    end
    form_helper
  end

  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration.blacklight_config,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      select_deselect_action: nil
    )
  end

  it 'uses the metadata field label' do
    render partial: p, locals: { key: 'some_key', config: field, f: }
    expect(rendered).to have_selector '.field-label', text: 'Some label'
  end

  it 'marks views as disabled if they are immutable' do
    allow(controller).to receive(:enabled_in_spotlight_view_type_configuration?).and_return(true)
    render partial: p, locals: { key: 'some_key', config: field, f: }
    expect(rendered).to have_selector 'input[disabled][name="z[some_key][another_view_type]"]'
  end
end
