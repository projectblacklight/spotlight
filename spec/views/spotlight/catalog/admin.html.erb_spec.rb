# frozen_string_literal: true

RSpec.describe 'spotlight/catalog/admin.html.erb', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_header_component) { instance_double(Blacklight::SearchHeaderComponent, render_in: true) }

  before do
    allow(exhibit).to receive(:blacklight_config).and_return(blacklight_config)
    assign(:exhibit, exhibit)
    assign(:response, [])
    stub_template '_zero_results.html.erb' => 'nuffin'
    stub_template '_results_pagination.html.erb' => '0'
    allow(blacklight_config.view_config(:admin_table).search_header_component).to receive(:new).and_return(search_header_component)
    allow(view).to receive_messages(
      blacklight_config: blacklight_config,
      spotlight_page_path_for: nil,
      current_exhibit: exhibit,
      new_exhibit_resource_path: '',
      exhibit_alt_text_path: '',
      reindex_all_exhibit_resources_path: '',
      monitor_exhibit_resources_path: '',
      can?: true
    )
  end

  it 'renders the sidebar' do
    render
    expect(view.content_for(:sidebar)).to have_link 'Browse'
  end

  it 'renders the search header' do
    render
    expect(search_header_component).to have_received(:render_in)
  end

  it "renders the 'add items' link if any repository sources are configured" do
    allow(Spotlight::Engine.config.spotlight).to receive(:resource_partials).and_return(['a'])
    render
    expect(rendered).to have_link 'Add items'
  end

  it "does not render the 'add items' link if no repository sources are configured" do
    allow(Spotlight::Engine.config.spotlight).to receive(:resource_partials).and_return([])
    render
    expect(rendered).to have_no_link 'Add items'
  end
end
