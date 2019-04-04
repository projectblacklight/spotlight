# frozen_string_literal: true

describe 'spotlight/search_configurations/_search_fields', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:f) do
    form_helper = nil
    controller.view_context.bootstrap_form_for(exhibit.blacklight_configuration, url: '/update') do |f|
      form_helper = f
    end
    form_helper
  end

  before do
    original_config = Spotlight::Engine.blacklight_config.deep_dup
    allow(Spotlight::Engine).to receive(:blacklight_config).and_return(original_config)
    original_config.add_search_field 'some_field_with_a_condition', if: ->(*_args) { false }
    assign(:exhibit, exhibit)
    assign(:blacklight_configuration, exhibit.blacklight_configuration)
    allow(view).to receive_messages(current_exhibit: exhibit)
    exhibit.blacklight_config.add_search_field 'some_hidden_field', include_in_simple_select: false
    exhibit.blacklight_config.add_search_field 'some_field with_a_space'
    render partial: 'spotlight/search_configurations/search_fields', locals: { f: f }
  end

  it 'has a fieldset with an appropriate legend' do
    expect(rendered).to have_selector 'fieldset legend', text: 'Field-based search'
  end

  it 'has a checkbox to enable or disable fielded search' do
    expect(rendered).to have_selector 'input[data-behavior="enable-feature"][data-target="#search_fields"]'
  end

  it 'has a read-only "everything" search option' do
    expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][all_fields][enabled]'][data-readonly='true']"
  end

  it 'has search options for available search fields' do
    expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][title][enabled]']"
    expect(rendered).to have_selector "input[name='blacklight_configuration[search_fields][author][enabled]']"
  end

  it 'excludes search options that do not show up in the search dropdown' do
    expect(rendered).not_to have_selector "input[name='blacklight_configuration[search_fields][autocomplete][enabled]']"
    expect(rendered).not_to have_selector "input[name='blacklight_configuration[search_fields][some_hidden_field][enabled]']"
  end

  it 'excludes search options that have if/unless configuration that causes them not to be displayed' do
    expect(rendered).not_to have_selector "input[name='blacklight_configuration[search_fields][some_field_with_a_condition][enabled]']"
  end

  it 'parameterizes the data-id attribute for search field key' do
    expect(rendered).to have_selector '[data-id="some_field-with_a_space-id"]'
  end
end
