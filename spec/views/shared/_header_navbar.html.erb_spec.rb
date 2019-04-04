# frozen_string_literal: true

describe 'shared/_header_navbar', type: :view do
  before do
    stub_template '_user_util_links.html.erb' => 'links'
  end

  it 'has nav links' do
    render
    expect(rendered).to have_selector '#user-util-collapse', text: 'links'
  end
end
