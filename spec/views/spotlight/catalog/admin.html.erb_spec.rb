require 'spec_helper'

module Spotlight
  describe "spotlight/catalog/admin.html.erb" do
    let(:exhibit) { stub_model(Spotlight::Exhibit)}
    before do
      view.stub(:blacklight_config).and_return(CatalogController.blacklight_config)
      view.stub(:spotlight_page_path_for).and_return(nil)
      view.stub(:current_exhibit).and_return(exhibit)
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
