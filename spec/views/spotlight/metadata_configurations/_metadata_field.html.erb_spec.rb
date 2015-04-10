require 'spec_helper'

module Spotlight
  describe 'spotlight/metadata_configurations/_metadata_field', type: :view do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:p) { 'spotlight/metadata_configurations/metadata_field.html.erb' }
    before do
      assign(:exhibit, exhibit)
      assign(:blacklight_configuration, exhibit.blacklight_configuration)
      allow(view).to receive_messages(
        current_exhibit: exhibit,
        blacklight_config: exhibit.blacklight_configuration,
        available_view_fields: { some_view_type: 1, another_view_type: 2 },
        select_deselect_button: nil)
    end

    let(:facet_field) { Blacklight::Configuration::FacetField.new }
    let(:builder) { ActionView::Helpers::FormBuilder.new 'z', nil, view, {} }

    it 'uses the index_field_label helper to render the label' do
      allow(view).to receive(:index_field_label).with(nil, 'some_key').and_return 'Some label'
      render partial: p, locals: { key: 'some_key', config: facet_field, f: builder }
      expect(rendered).to have_selector '.field-label', text: 'Some label'
    end
  end
end
