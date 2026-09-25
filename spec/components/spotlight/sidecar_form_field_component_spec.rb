# frozen_string_literal: true

RSpec.describe Spotlight::SidecarFormFieldComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:f) do
    form_helper = nil
    vc_test_controller.view_context.bootstrap_form_for('z', url: '/update') do |f|
      form_helper = f
    end
    form_helper
  end

  context 'with a text field' do
    let(:component) do
      described_class.new(form: f, id: 'title', label: 'Title', field_type: 'text_field', value: 'xyz', multiple: false, readonly: false, inline: false)
    end

    it 'renders a label and a single text input' do
      expect(rendered).to have_css('div.form-group.mb-3 label', text: 'Title')
      expect(rendered).to have_css("input[type='text'][class='form-control field-title'][value='xyz']")
    end
  end

  context 'with a text area field' do
    let(:component) do
      described_class.new(form: f, id: 'description', label: 'Description', field_type: 'text_area', value: nil, multiple: false, readonly: false,
                          inline: false)
    end

    it 'renders a label and a single text area input' do
      expect(rendered).to have_css('div.form-group.mb-3 label', text: 'Description')
      expect(rendered).to have_css("textarea[class='form-control field-description']")
    end
  end

  context 'with a multivalued field' do
    let(:component) do
      described_class.new(form: f, id: 'date', label: 'Date', field_type: 'text_field', value: %w[x y z], multiple: true, readonly: false, inline: false)
    end

    it 'renders a label and a multiple text inputs' do
      expect(rendered).to have_css('div.form-group.mb-3 label', text: 'Date')
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='x']")
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='y']")
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='z']")
    end
  end
end
