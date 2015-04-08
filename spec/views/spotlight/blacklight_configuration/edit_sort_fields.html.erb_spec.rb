require 'spec_helper'

module Spotlight
  describe 'spotlight/blacklight_configurations/edit_sort_fields', type: :view do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      assign(:exhibit, exhibit)
      assign(:blacklight_configuration, exhibit.blacklight_configuration)
      allow(view).to receive_messages(current_exhibit: exhibit, translate_sort_fields: '')
    end

    it 'has a disabled relevance sort option' do
      render

      expect(rendered).to have_selector "input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']"
    end
  end
end
