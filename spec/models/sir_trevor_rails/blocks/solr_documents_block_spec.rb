require 'spec_helper'

describe SirTrevorRails::Blocks::SolrDocumentsBlock do
  let(:page) { FactoryGirl.create(:feature_page) }
  let(:block_data) { {} }
  subject { described_class.new({ type: '', data: block_data }, page) }

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
end
