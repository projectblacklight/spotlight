require 'spec_helper'

module Spotlight
  describe "spotlight/catalog/admin.html.erb", :type => :view do
    let(:exhibit) { stub_model(Spotlight::Exhibit)}
    before do
      allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
      allow(view).to receive(:spotlight_page_path_for).and_return(nil)
      allow(view).to receive(:current_exhibit).and_return(exhibit)
      allow(view).to receive(:new_exhibit_catalog_path).and_return('')
      allow(view).to receive(:new_exhibit_resources_upload_path).and_return('')
      assign(:exhibit, exhibit)
    end
    it "should render the sidebar" do
      assign(:response, [])
      stub_template '_search_header.html.erb' => 'header'
      stub_template '_zero_results.html.erb' => 'nuffin'
      stub_template '_results_pagination.html.erb' => '0'
      render
      expect(rendered).to have_link 'Browse'
    end
  end
end
