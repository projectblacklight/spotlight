require 'spec_helper'

describe "spotlight/home_pages/_sidebar.html.erb" do
  before do
    stub_template 'catalog/_search_sidebar.html.erb' => "Sidebar"
  end

  it { render; expect(rendered).to match "Sidebar"  }

end


