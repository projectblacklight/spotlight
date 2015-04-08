require 'spec_helper'

module Spotlight
  describe 'spotlight/pages/new', type: :view do
    let(:exhibit) { stub_model(Exhibit) }
    before do
      assign(:page, stub_model(FeaturePage, exhibit: exhibit).as_new_record)
      allow(view).to receive_messages(default_thumbnail_jcrop_options: {}, available_index_fields: [], available_view_fields: [])
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
end
