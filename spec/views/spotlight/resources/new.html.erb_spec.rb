
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
    allow(Spotlight::Engine.config).to receive(:resource_partials).and_return(
      %w(
        spotlight/resources/external_resources_form
        spotlight/resources/upload/form
        spotlight/resources/csv_upload/form
      )
    )
    stub_template 'spotlight/resources/_external_resources_form.html.erb' => 'a_template'
    stub_template 'spotlight/resources/upload/_form.html.erb' => 'b_template'
    stub_template 'spotlight/resources/csv_upload/_form.html.erb' => 'c_template'
    render
    expect(rendered).to have_content 'a_template'
    expect(rendered).to have_content 'b_template'
    expect(rendered).to have_content 'c_template'
  end
end
