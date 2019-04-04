# frozen_string_literal: true

describe Spotlight::MetaHelper, type: :helper do
  describe '#add_exhibit_meta_content' do
    let(:current_exhibit) { FactoryBot.create(:exhibit) }
    before do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      allow(helper).to receive(:site_title).and_return('some title')
      current_exhibit.subtitle = 'xyz'
      current_exhibit.description = 'abc'
      TopHat.current['twitter_card'] = nil
      TopHat.current['opengraph'] = nil
    end

    it 'generates a twitter card for the exhibit' do
      allow(helper).to receive(:exhibit_root_url).and_return('some/url')
      allow(current_exhibit).to receive(:thumbnail).and_return(double(iiif_url: 'https://test.host/images/7777/full/400,300/0/default.jpg'))

      helper.add_exhibit_meta_content

      card = helper.twitter_card
      expect(card).to have_css "meta[name='twitter:card'][value='summary']", visible: false
      expect(card).to have_css "meta[name='twitter:url'][value='some/url']", visible: false
      expect(card).to have_css "meta[name='twitter:title'][value='#{current_exhibit.title}']", visible: false
      expect(card).to have_css "meta[name='twitter:description'][value='#{current_exhibit.subtitle}']", visible: false
      expect(card).to have_css "meta[name='twitter:image'][value='https://test.host/images/7777/full/400,300/0/default.jpg']", visible: false

      graph = helper.opengraph
      expect(graph).to have_css "meta[property='og:site_name'][content='some title']", visible: false
    end
  end
end
