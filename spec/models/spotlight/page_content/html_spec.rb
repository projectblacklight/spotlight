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

    it 'removes scripts, event handlers, styles, and javascript: links' do
      html = '<p onclick="alert(1)" style="color: red">hi</p><script>alert(2)</script><a href="javascript:alert(3)">x</a>'
      sanitized = described_class.sanitize(html)
      expect(sanitized).not_to include('<script', 'onclick', 'style', 'javascript:')
      expect(sanitized).to start_with '<p>hi</p>'
    end
  end
end
