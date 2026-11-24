# frozen_string_literal: true

RSpec.describe 'spotlight/searches/edit.html.erb', type: :view do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field :some_field
    end
  end
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:search) do
    stub_model(Spotlight::Search, exhibit:,
                                  id: 99, title: 'Title1', query_params: { f: { 'some_field' => ['xyz'] } })
  end

  before do
    view.extend(Spotlight::ApplicationHelper)
    allow(controller).to receive(:search_state_class).and_return(Blacklight::SearchState)

    assign(:exhibit, exhibit)
    assign(:search, search)
    allow(view).to receive_messages(
      search_action_path: '/search',
      mastheads_path: '/mastheads',
      featured_images_path: '/featured_images',
      exhibit_search_path: '/search',
      exhibit_searches_path: '/searches',
      exhibit_alt_text_path: '/alt-text',
      blacklight_config: blacklight_config,
      current_exhibit: exhibit
    )
  end

  it 'renders a form w/ the appropriate autocomplete data attribute' do
    render
    expect(rendered).to have_css 'form[data-autocomplete-exhibit-catalog-path]'
  end

  it 'renders active search constraints' do
    render
    expect(rendered).to have_css '.appliedParams .constraint-value'
    expect(rendered).to have_css '.appliedParams .constraint-value .filter-name', text: 'Some Field'
    expect(rendered).to have_css '.appliedParams .constraint-value .filter-value', text: 'xyz'
  end
end
