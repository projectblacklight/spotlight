require 'spec_helper'

describe 'spotlight/home_pages/_sidebar.html.erb', type: :view do
  before do
    stub_template 'catalog/_search_sidebar.html.erb' => 'Search Sidebar'
  end

  it 'has a search sidebar' do
    render
    expect(rendered).to match 'Search Sidebar'
  end
end
