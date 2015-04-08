require 'spec_helper'

module Spotlight
  describe 'spotlight/pages/edit', type: :view do
    let(:exhibit) { stub_model(Exhibit) }
    let(:page) { stub_model(FeaturePage, exhibit: exhibit) }
    before do
      assign(:page, page)
      allow(view).to receive_messages(default_thumbnail_jcrop_options: {}, available_index_fields: [], available_view_fields: [])
    end

    it 'renders the edit page form' do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select 'form[action=?][method=?]', spotlight.exhibit_feature_page_path(page.exhibit, page), 'post' do
        assert_select 'input#feature_page_title[name=?]', 'feature_page[title]'
        assert_select 'textarea#feature_page_content[name=?]', 'feature_page[content]'
      end
    end

    describe 'locks' do
      let(:lock) { Lock.create! on: page }

      before do
        page.lock = lock
      end

      it 'renders a lock' do
        render

        expect(rendered).to have_css '.alert-lock'
      end

      it 'does not render an old lock' do
        lock.created_at -= 1.day

        render

        expect(rendered).not_to have_css '.alert-lock'
      end

      it 'does not render a lock held by the current session' do
        lock.current_session!

        render

        expect(rendered).not_to have_css '.alert-lock'
      end

      it 'attaches a data-lock attribute to the cancel button' do
        lock.current_session!

        render

        expect(rendered).to have_link 'Cancel'
        expect(rendered).to have_css "a[data-lock=\"#{url_for([spotlight, page.exhibit, lock])}\"]", text: 'Cancel'
      end

      it "does not have data-lock attribute if the lock doesn't belong to this session" do
        render

        expect(rendered).to have_link 'Cancel'
        expect(rendered).not_to have_css 'a[data-lock]', text: 'Cancel'
      end
    end
  end
end
