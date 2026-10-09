# frozen_string_literal: true

RSpec.describe Spotlight::PageContent::Html do
  let(:page) { FactoryBot.build(:feature_page, content_type: 'Html', content: html) }
  let(:html) { '<h2>Heading</h2><p>Some <strong>text</strong></p>' }

  describe '.parse' do
    it 'returns the content as a single HTML fragment' do
      content = described_class.parse(page, :content)
      expect(content.length).to eq 1
      expect(content.first).to be_a Spotlight::PageContent::Html::Fragment
      expect(content.first.html).to eq html
    end

    context 'with blank content' do
      let(:html) { nil }

      it 'returns no content' do
        expect(described_class.parse(page, :content)).to eq []
      end
    end
  end

  describe '.sanitize' do
    it 'keeps the formatting produced by the editor' do
      html = '<h3>Title</h3><ul><li><p><em>one</em></p></li></ul><blockquote><p>q</p></blockquote>' \
             '<table><tbody><tr><th colspan="2"><p>h</p></th></tr></tbody></table>' \
             '<p><a href="https://example.com" target="_blank" rel="noopener noreferrer nofollow">link</a></p>'
      expect(described_class.sanitize(html)).to eq html
    end

    it 'keeps images from the editor' do
      html = '<img src="/uploads/spotlight/attachment/file/1/a.png" alt="A map" data-size="small" data-align="left">' \
             '<img src="https://example.com/b.png" alt="" data-size="full" data-align="center" data-decorative="true">'
      expect(described_class.sanitize(html)).to eq html
    end

    it 'removes images that are not from http(s) or this site' do
      %w[javascript:alert(1) data:image/png;base64,AAAA //evil.example.com/a.png a.png].each do |src|
        expect(described_class.sanitize(%(<p>x</p><img src="#{src}" alt="a">))).to eq '<p>x</p>'
      end
    end

    it 'removes unknown image size, alignment, and decorative values' do
      html = '<img src="/a.png" alt="a" data-size="huge" data-align="top" data-decorative="maybe" width="5">'
      expect(described_class.sanitize(html)).to eq '<img src="/a.png" alt="a">'
    end

    it 'removes scripts, event handlers, styles, and javascript: links' do
      html = '<p onclick="alert(1)" style="color: red">hi</p><script>alert(2)</script><a href="javascript:alert(3)">x</a>'
      sanitized = described_class.sanitize(html)
      expect(sanitized).not_to include('<script', 'onclick', 'style', 'javascript:')
      expect(sanitized).to start_with '<p>hi</p>'
    end
  end

  describe 'embedded blocks' do
    def embed(type, data)
      %(<div data-spotlight-block="#{type}" data-spotlight-block-data="#{ERB::Util.html_escape(data.to_json)}"></div>)
    end

    let(:grid_data) { { 'item' => { 'item_0' => { 'id' => 'dq287tq6352', 'display' => 'true', 'weight' => '0' } } } }

    describe '.sanitize' do
      it 'keeps valid embedded blocks' do
        html = "<p>Before</p>#{embed('solr_documents_grid', grid_data)}<p>After</p>"
        expect(described_class.sanitize(html)).to eq html
      end

      it 'drops block data that HTML pages do not use' do
        sanitized = described_class.sanitize(embed('solr_documents', grid_data.merge('text' => '<script>x()</script>', 'title' => 'T')))
        expect(sanitized).to eq embed('solr_documents', grid_data)
      end

      it 'removes embeds of other block types, with invalid data, or nested in other content' do
        html = "#{embed('rule', {})}<div data-spotlight-block=\"solr_documents\" data-spotlight-block-data=\"nope\"></div>" \
               "<blockquote>#{embed('solr_documents', grid_data)}</blockquote>"
        expect(described_class.sanitize(html)).to eq '<blockquote></blockquote>'
      end

      it 'unwraps other divs, checking what they contain' do
        html = "<div><p>Text</p><div>#{embed('solr_documents', grid_data)}</div></div>"
        expect(described_class.sanitize(html)).to eq '<p>Text</p>'
      end

      it 'removes embeds of widgets that are not configured' do
        allow(Spotlight::Engine.config).to receive(:sir_trevor_widgets).and_return(%w[SolrDocuments])
        expect(described_class.sanitize(embed('solr_documents_grid', grid_data))).to eq ''
      end
    end

    describe '.parse' do
      let(:html) { "<h2>Title</h2><p>Before</p>#{embed('solr_documents_grid', grid_data)}<p>After</p>#{embed('solr_documents_carousel', {})}" }

      it 'splits the content into HTML fragments and SirTrevor blocks' do
        content = described_class.parse(page, :content)
        expect(content.map(&:class)).to eq [
          Spotlight::PageContent::Html::Fragment, SirTrevorRails::Blocks::SolrDocumentsGridBlock,
          Spotlight::PageContent::Html::Fragment, SirTrevorRails::Blocks::SolrDocumentsCarouselBlock
        ]
        expect(content.first.html).to eq '<h2>Title</h2><p>Before</p>'
        expect(content.second.item_ids).to eq ['dq287tq6352']
        expect(content.second.parent).to eq page
      end
    end
  end

  describe Spotlight::PageContent::Html::Fragment do
    subject(:fragment) { described_class.new(html) }

    context 'without images' do
      let(:html) { '<p>Just text</p>' }

      it 'does not need alt text' do
        expect(fragment.supports_alt_text?).to be false
        expect(fragment.item).to eq({})
      end
    end

    context 'with images' do
      let(:html) { '<img src="/a.png" alt="A map"><p>x</p><img src="/b.png" alt="" data-decorative="true"><img src="/c.png">' }

      it 'reports each image for the alt text report' do
        expect(fragment.supports_alt_text?).to be true
        expect(fragment.item).to eq(
          '0' => { 'alt_text' => 'A map', 'decorative' => nil },
          '1' => { 'alt_text' => '', 'decorative' => 'true' },
          '2' => { 'alt_text' => nil, 'decorative' => nil }
        )
      end
    end

    it 'sanitizes when rendering' do
      expect(described_class.new('<p onclick="x()">hi</p><img src="javascript:x()">').to_html).to eq '<p>hi</p>'
    end
  end
end
