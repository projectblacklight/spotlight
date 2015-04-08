require 'spec_helper'

describe 'spotlight/browse/_sort_and_per_page', type: :view do
  let :blacklight_config do
    Blacklight::Configuration.new
  end

  before do
    allow(view).to receive_messages(blacklight_config: blacklight_config)
  end

  it 'renders the pagination, sort, per page and view type controls' do
    stub_template '_paginate_compact.html.erb' => "paginate_compact\n"
    stub_template '_sort_widget.html.erb' => "sort_widget\n"
    stub_template '_per_page_widget.html.erb' => "per_page_widget\n"
    stub_template '_view_type_group.html.erb' => "view_type_group\n"
    render
    expect(rendered).to_not have_content 'paginate_compact'
    expect(rendered).to have_content 'sort_widget'
    expect(rendered).to have_content 'per_page_widget'
    expect(rendered).to have_content 'view_type_group'
  end
end
