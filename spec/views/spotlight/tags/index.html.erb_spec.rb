# frozen_string_literal: true

describe 'spotlight/tags/index.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:tag1) { FactoryBot.create(:tagging, tagger: exhibit, taggable: exhibit) }
  let!(:tag2) { FactoryBot.create(:tagging, tagger: exhibit, taggable: exhibit) }

  before do
    assign(:exhibit, exhibit)
    assign(:tags, exhibit.owned_tags)
    allow(view).to receive_messages(exhibit_tag_path: '/tags')
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    allow(view).to receive(:url_to_tag_facet, &:first)
    allow(view).to receive_messages(update_all_exhibit_tags_path: '/update_all')
    allow(view).to receive(:exhibit_path)
  end

  describe 'Tags' do
    it 'is displayed' do
      render
      puts rendered
      [tag1.tag.name, tag2.tag.name].each do |name|
        expect(rendered).to have_css('h4', text: name)
        expect(rendered).to have_link(name, href: '#edit-in-place')
      end
    end
  end
end
