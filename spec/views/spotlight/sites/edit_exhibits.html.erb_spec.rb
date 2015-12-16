require 'spec_helper'

module Spotlight
  describe 'spotlight/sites/edit_exhibits', type: :view do
    let!(:exhibit_a) { FactoryGirl.create(:exhibit) }
    let!(:exhibit_b) { FactoryGirl.create(:exhibit) }

    before do
      assign(:site, Spotlight::Site.instance)
      allow(view).to receive_messages(exhibit_path: nil)
    end

    it 'has columns for the exhibit data' do
      render

      expect(rendered).to have_selector 'th', text: 'Title'
      expect(rendered).to have_selector 'th', text: 'Published?'
      expect(rendered).to have_selector 'th', text: 'Requested by'
      expect(rendered).to have_selector 'th', text: 'Created at'
      expect(rendered).to have_selector 'th', text: 'Updated at'
    end

    it 'has draggable rows for each exhibit' do
      render

      expect(rendered).to have_selector 'tr .dd-handle', count: 2
    end
  end
end
