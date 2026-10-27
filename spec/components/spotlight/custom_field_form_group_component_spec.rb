# frozen_string_literal: true

RSpec.describe Spotlight::CustomFieldFormGroupComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(form: f, field:, value: 'b') }
  let(:f) { BootstrapForm::FormBuilder.new('data', nil, vc_test_controller.view_context, {}) }
  let(:field) { FactoryBot.create(:custom_field, field_type: 'text', is_multiple: true) }

  it 'renders the field with its configured component and input type' do
    expect(rendered).to have_css 'label.form-label', text: 'Some Field'
    expect(rendered).to have_css "textarea[name='data[#{field.slug}][]']", text: 'b'
  end

  context 'when the application overrides the form_group partial' do
    before do
      allow(vc_test_controller.lookup_context).to receive(:exists?).and_call_original
      allow(vc_test_controller.lookup_context).to receive(:exists?).with('spotlight/custom_fields/form_group/text', [], true).and_return(true)
      allow(Spotlight.deprecator).to receive(:warn)
      allow(component).to receive(:render).and_call_original
      allow(component).to receive(:render).with(hash_including(partial: 'spotlight/custom_fields/form_group/text')).and_return('deprecated partial')
    end

    it 'renders the partial with a deprecation warning' do
      expect(rendered).to have_text 'deprecated partial'
      expect(Spotlight.deprecator).to have_received(:warn).with(/form_group/)
      expect(component).to have_received(:render).with(
        partial: 'spotlight/custom_fields/form_group/text', locals: { inline: false, f:, field:, value: 'b' }
      )
    end
  end
end
