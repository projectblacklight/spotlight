require 'spec_helper'

module Spotlight
  describe "spotlight/catalog/index.html.erb" do
    before do
      view.stub(:blacklight_config).and_return(CatalogController.blacklight_config)
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
