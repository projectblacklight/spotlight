# frozen_string_literal: true

describe Spotlight::MetaHelper, type: :helper do
  describe '#add_exhibit_meta_content' do
    let(:current_exhibit) { FactoryBot.create(:exhibit) }

    before do
      allow(helper).to receive_messages(current_exhibit:)
      allow(helper).to receive(:site_title).and_return('some title')
      current_exhibit.subtitle = 'xyz'
      current_exhibit.description = 'abc'
    end

    it 'generates a twitter card for the exhibit' do
      allow(helper).to receive(:exhibit_root_url).and_return('some/url')
      allow(current_exhibit).to receive(:thumbnail).and_return(double(iiif_url: 'https://test.host/images/7777/full/400,300/0/default.jpg'))

      helper.add_exhibit_meta_content

      expect(view.content_for(:meta)).to include('<meta name="twitter:card" content="summary">')
      expect(view.content_for(:meta)).to include('<meta name="twitter:url" content="some/url">')
      expect(view.content_for(:meta)).to include("<meta name=\"twitter:title\" content=\"#{current_exhibit.title}\">")
      expect(view.content_for(:meta)).to include("<meta name=\"twitter:description\" content=\"#{current_exhibit.subtitle}\">")
      expect(view.content_for(:meta)).to include('<meta name="twitter:image" content="https://test.host/images/7777/full/400,300/0/default.jpg">')

      expect(view.content_for(:meta)).to include('<meta property="og:site_name" content="some title">')
    end
  end
end
