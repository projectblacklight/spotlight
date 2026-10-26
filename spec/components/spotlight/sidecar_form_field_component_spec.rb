# frozen_string_literal: true

RSpec.describe Spotlight::SidecarFormFieldComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:form_options) { {} }
  let(:f) { BootstrapForm::FormBuilder.new('z', nil, vc_test_controller.view_context, form_options) }

  context 'with a text field' do
    let(:component) do
      described_class.new(form: f, id: 'title', label: 'Title', field_type: 'text_field', value: 'xyz', multiple: false, readonly: false, inline: false)
    end

    it 'renders a label and a single text input' do
      expect(rendered).to have_css('div.form-group.mb-3 > label.form-label', text: 'Title')
      expect(rendered).to have_css("input[type='text'][class='form-control field-title'][value='xyz']")
    end
  end

  context 'with a text area field' do
    let(:component) do
      described_class.new(form: f, id: 'description', label: 'Description', field_type: 'text_area', value: nil, multiple: false, readonly: false,
                          inline: false)
    end

    it 'renders a label and a single text area input' do
      expect(rendered).to have_css('div.form-group.mb-3 > label.form-label', text: 'Description')
      expect(rendered).to have_css("textarea[class='form-control field-description']")
    end
  end

  context 'with a multivalued field' do
    let(:component) do
      described_class.new(form: f, id: 'date', label: 'Date', field_type: 'text_field', value: %w[x y z], multiple: true, readonly: false, inline: false)
    end

    it 'renders a label and a multiple text inputs' do
      expect(rendered).to have_css('div.form-group.mb-3 > label.form-label', text: 'Date')
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='x']")
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='y']")
      expect(rendered).to have_css("input[type='text'][class='form-control field-date'][value='z']")
    end
  end

  context 'with another field type' do
    let(:component) do
      described_class.new(form: f, id: 'email', label: 'Email', field_type: 'email_field', value: %w[person@example.com], multiple: true)
    end

    it 'renders a label and field type input' do
      expect(rendered).to have_css('div.form-group.mb-3 > label.form-label', text: 'Email')
      expect(rendered).to have_css('input[type="email"][class="form-control field-email"][value="person@example.com"]')
    end
  end

  context 'with a multivalued field in a horizontal form' do
    let(:form_options) { { layout: :horizontal, label_col: 'col-md-2', control_col: 'col-md-6' } }

    let(:component) do
      described_class.new(form: f, id: 'date', label: 'Date', value: %w[x y], multiple: true, inline: true)
    end

    it 'renders the first value beside the label and offsets later values' do
      expect(rendered).to have_css('div.form-group.mb-3.row > label.col-form-label.col-md-2', text: 'Date')
      expect(rendered).to have_css('div.col-md-6:not(.offset-md-2) > input[value="x"]')
      expect(rendered).to have_css('div.offset-md-2.col-md-6 > input[value="y"]')
    end
  end
end
