# frozen_string_literal: true

RSpec.describe 'spotlight/metadata_configurations/edit', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:default_language) { true }

  before do
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_configuration.blacklight_config,
      available_view_fields: { some_view_type: 1, another_view_type: 2 },
      exhibit_alt_text_path: '/',
      select_deselect_action: nil,
      default_language?: default_language
    )
    allow(controller).to receive(:enabled_in_spotlight_view_type_configuration?).and_return(true)
  end

  it 'has columns for the available view types' do
    render
    expect(rendered).to have_selector 'th', text: 'Some View Type'
    expect(rendered).to have_selector 'th', text: 'Another View Type'
  end

  describe 'when a locale other than the default is set' do
    let(:default_language) { false }

    before { render }

    it 'removes the form and displays a translations message' do
      expect(rendered).to have_text 'Please use the translations editor'
      expect(rendered).to have_no_selector 'th', text: 'Some View Type'
      expect(rendered).to have_no_selector 'th', text: 'Another View Type'
    end
  end
end
