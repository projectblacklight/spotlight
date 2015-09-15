require 'spec_helper'

describe 'spotlight/tags/index.html.erb', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:tag1) { FactoryGirl.create(:tagging, tagger: exhibit) }
  let!(:tag2) { FactoryGirl.create(:tagging, tagger: exhibit) }
  before do
    assign(:exhibit, exhibit)
    assign(:tags, exhibit.owned_tags)
    allow(view).to receive_messages(exhibit_tag_path: '/tags')
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    allow(view).to receive(:url_to_tag_facet, &:first)
  end
  describe 'Tags' do
    it 'is displayed' do
      render
      [tag1.tag.name, tag2.tag.name].each do |name|
        expect(rendered).to have_css('td', text: name)
      end
    end
  end
  describe 'Total tags' do
    it 'is displayed' do
      render
      expect(rendered).to have_css('span.label.label-default', text: 2)
    end
  end
end
