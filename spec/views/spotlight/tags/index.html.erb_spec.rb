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
  end

  describe 'Tags' do
    it 'is displayed' do
      render
      [tag1.tag.name, tag2.tag.name].each do |name|
        expect(rendered).to have_css('td', text: name)
        expect(rendered).to have_link(name, href: 't')
      end
    end
  end
end
