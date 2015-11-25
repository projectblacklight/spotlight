require 'spec_helper'

module Spotlight
  describe 'spotlight/search_configurations/_search_fields', type: :view do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      assign(:exhibit, exhibit)
      assign(:blacklight_configuration, exhibit.blacklight_configuration)
      allow(view).to receive_messages(current_exhibit: exhibit)

      exhibit.blacklight_config.add_search_field 'some_hidden_field', include_in_simple_select: false
    end

    let(:f) do
      form_helper = nil
      controller.view_context.bootstrap_form_for(exhibit.blacklight_configuration, url: '/update') do |f|
        form_helper = f
      end

      form_helper
    end

    it 'has a fieldset with an appropriate legend' do
      render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }

      expect(rendered).to have_selector 'fieldset legend', text: 'Field-based search'
    end

    it 'has a checkbox to enable or disable fielded search' do
      render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }

      expect(rendered).to have_selector 'input[data-behavior="enable-feature"][data-target="#search_fields"]'
    end

    it 'has a read-only "everything" search option' do
      render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }
      expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][all_fields][enabled]'][data-readonly='true']"
    end

    it 'has search options for available search fields' do
      render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }

      expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][title][enabled]']"
      expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][author][enabled]']"
    end

    it 'excludes search options that do not show up in the search dropdown' do
      render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }

      expect(rendered).not_to have_selector "input[name='blacklight_configuration[search_fields][autocomplete][enabled]']"
      expect(rendered).not_to have_selector "input[name='blacklight_configuration[search_fields][some_hidden_field][enabled]']"
    end
  end
end
