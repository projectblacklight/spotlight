require 'spec_helper'

module Spotlight
  describe 'spotlight/catalog/admin.html.erb', type: :view do
    let(:exhibit) { stub_model(Spotlight::Exhibit) }
    before do
      allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
      allow(view).to receive(:spotlight_page_path_for).and_return(nil)
      allow(view).to receive(:current_exhibit).and_return(exhibit)
      allow(view).to receive(:new_exhibit_resource_path).and_return('')
      allow(view).to receive(:reindex_all_exhibit_resources_path).and_return('')
      allow(view).to receive(:monitor_exhibit_resources_path).and_return('')
      assign(:exhibit, exhibit)
      assign(:response, [])
      stub_template '_search_header.html.erb' => 'header'
      stub_template '_zero_results.html.erb' => 'nuffin'
      stub_template '_results_pagination.html.erb' => '0'
      allow(view).to receive(:can?).and_return(true)
    end
    it 'renders the sidebar' do
      render
      expect(rendered).to have_link 'Browse'
    end

    it "renders the 'add items' link if any repository sources are configured" do
      allow(Spotlight::Engine.config).to receive(:resource_partials).and_return(['a'])
      render
      expect(rendered).to have_link 'Add items'
    end

    it "does not render the 'add items' link if no repository sources are configured" do
      allow(Spotlight::Engine.config).to receive(:resource_partials).and_return([])
      render
      expect(rendered).not_to have_link 'Add items'
    end
  end
end
