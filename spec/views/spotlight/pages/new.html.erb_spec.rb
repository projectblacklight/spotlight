describe 'spotlight/pages/new', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    assign(:page, stub_model(Spotlight::FeaturePage, exhibit: exhibit).as_new_record)
    allow(view).to receive_messages(configurations_for_current_page: {},
                                    featured_images_path: '/foo')
  end

  it 'renders new page form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form[action=?][method=?]', spotlight.exhibit_feature_pages_path(exhibit), 'post' do
      assert_select 'input#feature_page_title[name=?]', 'feature_page[title]'
      assert_select 'textarea#feature_page_content[name=?]', 'feature_page[content]'
    end
  end
end
