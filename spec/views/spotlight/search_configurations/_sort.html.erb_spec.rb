# frozen_string_literal: true

describe 'spotlight/search_configurations/_sort', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    original_config = Spotlight::Engine.blacklight_config.deep_dup
    allow(Spotlight::Engine).to receive(:blacklight_config).and_return(original_config)
    original_config.add_sort_field 'some_disabled_field', if: ->(*_args) { false }
    exhibit.blacklight_config.add_sort_field 'sort_title_ssi asc, plus_another_field desc', label: 'TestSort'
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      translate_sort_fields: ''
    )
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

  it 'parameterizes the data-id attribute for sort fields (e.g. when no key is supplied and the sort is used as the key)' do
    render partial: 'spotlight/search_configurations/sort', locals: { f: f }
    expect(rendered).to have_css('[data-id="sort_title_ssi-asc-plus_another_field-desc-id"]')
  end

  it 'hides fields that are configured not to display' do
    render partial: 'spotlight/search_configurations/sort', locals: { f: f }
    expect(rendered).not_to have_css('[data-id="some_disabled_field-id"]')
  end
end
