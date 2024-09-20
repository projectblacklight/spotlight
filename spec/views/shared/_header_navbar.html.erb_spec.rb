# frozen_string_literal: true

describe 'shared/_header_navbar', type: :view do
  before do
    allow(view).to receive(:blacklight_config).and_return(Blacklight.default_configuration)
    stub_template 'shared/_user_util_links.html.erb' => 'links'
  end

  it 'has nav links' do
    render
    expect(rendered).to have_selector '#user-util-collapse', text: 'links'
  end
end
