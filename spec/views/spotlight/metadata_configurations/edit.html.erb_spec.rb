require 'spec_helper'

module Spotlight
  describe 'spotlight/metadata_configurations/edit', type: :view do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      assign(:exhibit, exhibit)
      assign(:blacklight_configuration, exhibit.blacklight_configuration)
      allow(view).to receive_messages(
        current_exhibit: exhibit,
        blacklight_config: exhibit.blacklight_configuration,
        available_view_fields: { some_view_type: 1, another_view_type: 2 },
        select_deselect_button: nil)
    end

    it 'has columns for the available view types' do
      render
      expect(rendered).to have_selector 'th', text: 'Some View Type'
      expect(rendered).to have_selector 'th', text: 'Another View Type'
    end
  end
end
