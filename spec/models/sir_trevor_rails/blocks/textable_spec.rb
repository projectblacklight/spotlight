require 'spec_helper'

describe SirTrevorRails::Blocks::Textable do
  class TextableTestClass
    include SirTrevorRails::Blocks::Textable
    attr_accessor :text
  end
  let(:subject) { TextableTestClass.new }
  let(:st_blank_text) { '<p><br></p>' }
  describe '#text?' do
    it 'returns false when there is no text' do
      expect(subject.text?).to be_falsey
    end
    it 'returns true false when the text is the default sir-trevor text' do
      allow(subject).to receive_messages(text: st_blank_text)
      expect(subject.text?).to be_truthy
    end
  end
  describe '#text_align' do
    it 'proxies the sir-trevor text-align attribute' do
      allow(subject).to receive_messages('text-align' => 'text-align-value')
      expect(subject.text_align).to eq 'text-align-value'
    end
  end
  describe '#content_align' do
    it 'is the reverse of text-align' do
      allow(subject).to receive_messages(text: 'TextContent')
      allow(subject).to receive_messages(text_align: 'left')
      expect(subject.content_align).to eq 'right'
      allow(subject).to receive_messages(text_align: 'right')
      expect(subject.content_align).to eq 'left'
    end
    it 'does not have any alignment if there is no text' do
      expect(subject.content_align).to be_nil
    end
  end
end
