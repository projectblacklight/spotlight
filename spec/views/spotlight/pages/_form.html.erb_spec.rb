describe 'spotlight/pages/edit', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:page) { stub_model(Spotlight::FeaturePage, exhibit: exhibit) }
  let :blacklight_config do
    Blacklight::Configuration.new
  end
  before do
    assign(:page, page)
    allow(view).to receive_messages(configurations_for_current_page: {},
                                    featured_images_path: '/foo')
  end

  it 'contains data-block-types attribute needed for SirTrevor instantiation' do
    render
    expect(rendered).to have_css '.js-st-instance[data-block-types]'
  end
end
