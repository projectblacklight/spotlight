require 'spec_helper'

describe 'spotlight/resources/new.html.erb', type: :view do
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:exhibit) { stub_model(Spotlight::Exhibit) }

  before do
    allow(view).to receive_messages(blacklight_config: blacklight_config)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    allow(view).to receive_messages(current_page?: true)
    stub_template 'spotlight/shared/_curation_sidebar.html.erb' => ''
  end

  it 'renders the configured partials' do
    allow(Spotlight::Engine.config).to receive(:resource_partials).and_return(%w(a b c))
    stub_template '_a.html.erb' => 'a_template'
    stub_template '_b.html.erb' => 'b_template'
    stub_template '_c.html.erb' => 'c_template'
    render
    expect(rendered).to have_content 'a_template'
    expect(rendered).to have_content 'b_template'
    expect(rendered).to have_content 'c_template'
  end
end
