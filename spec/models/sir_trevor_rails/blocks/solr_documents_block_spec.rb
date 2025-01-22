# frozen_string_literal: true

RSpec.describe SirTrevorRails::Blocks::SolrDocumentsBlock do
  subject { described_class.new({ type: '', data: block_data }, page) }

  let(:page) { FactoryBot.create(:feature_page) }
  let(:block_data) { {} }

  describe '#text' do
    it "is the block's text data" do
      block_data[:text] = 'abc'

      expect(subject.text).to eq 'abc'
    end

    it "squelches sir-trevor's placeholder values" do
      block_data[:text] = '<p><br></p>'
      expect(subject.text).to be_blank
    end
  end

  describe '#primary_caption?' do
    it 'is false if the primary caption field is not configured' do
      block_data['show-primary-caption'] = 'true'
      expect(subject.primary_caption?).to eq false
    end

    it 'is false if the field is configured not to show' do
      block_data['primary-caption-field'] = 'some_field'
      block_data['show-primary-caption'] = 'false'
      expect(subject.primary_caption?).to eq false
    end

    it 'is true if the field is configured to show' do
      block_data['primary-caption-field'] = 'some_field'
      block_data['show-primary-caption'] = 'true'
      expect(subject.primary_caption?).to eq true
    end
  end

  describe '#secondary_caption?' do
    it 'is false if the secondary caption field is not configured' do
      block_data['show-secondary-caption'] = 'true'
      expect(subject.secondary_caption?).to eq false
    end

    it 'is false if the field is configured not to show' do
      block_data['secondary-caption-field'] = 'some_field'
      block_data['show-secondary-caption'] = 'false'
      expect(subject.secondary_caption?).to eq false
    end

    it 'is true if the field is configured to show' do
      block_data['secondary-caption-field'] = 'some_field'
      block_data['show-secondary-caption'] = 'true'
      expect(subject.secondary_caption?).to eq true
    end
  end
end
