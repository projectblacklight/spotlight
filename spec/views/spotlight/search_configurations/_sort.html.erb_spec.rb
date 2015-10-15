require 'spec_helper'

module Spotlight
  describe 'spotlight/search_configurations/_sort', type: :view do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      assign(:exhibit, exhibit)
      assign(:blacklight_configuration, exhibit.blacklight_configuration)
      allow(view).to receive_messages(
        current_exhibit: exhibit,
        translate_sort_fields: '')
    end

    let(:f) do
      form_helper = nil
      controller.view_context.bootstrap_form_for(exhibit.blacklight_configuration, url: '/update') do |f|
        form_helper = f
      end

      form_helper
    end

    it 'has a disabled relevance sort option' do
      render partial: 'spotlight/search_configurations/sort', locals: { f: f }
      expect(rendered).to have_selector "input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']"
    end
  end
end
