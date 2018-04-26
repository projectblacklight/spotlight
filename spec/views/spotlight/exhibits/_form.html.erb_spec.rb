describe 'spotlight/exhibits/_form', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  before do
    assign(:exhibit, exhibit)
  end
  context 'when using default language' do
    before do
      allow(view).to receive_messages(
        default_language?: true
      )
    end

    it 'allows an editable title' do
      render
      expect(rendered).to have_selector 'input[name="exhibit[title]"]'
      expect(rendered).not_to have_selector 'input[name="exhibit[title]"][disabled="disabled"]'
      expect(rendered).not_to have_content 'This field is not editable in the current language. Switch to the default language to edit it.'
    end
  end
  context 'when using non-default language' do
    before do
      allow(view).to receive_messages(
        default_language?: false
      )
    end

    it 'disables editable title with help text' do
      render
      expect(rendered).to have_selector 'input[name="exhibit[title]"][disabled="disabled"]'
      expect(rendered).to have_content 'This field is not editable in the current language. Switch to the default language to edit it.'
    end
  end
end
