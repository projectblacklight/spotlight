RSpec.describe IIIFUrl do
  context 'for a valid url' do
    let(:url) { 'https://exhibits-stage.stanford.edu/images/78/square/400,/0/default.jpg' }
    let(:instance) { described_class.new url }

    describe 'to_s' do
      subject { instance.to_s }
      it { is_expected.to eq url }

      context 'after updating size' do
        before do
          instance.size = '300,'
        end
        it { is_expected.to eq 'https://exhibits-stage.stanford.edu/images/78/square/300,/0/default.jpg' }
      end
    end
  end

  context 'for an invalid url' do
    let(:url) { 'https://exhibits-stage.stanford.edu/square/400,/0/default.jpg' }
    it 'raises an error' do
      expect { described_class.new url }.to raise_error ArgumentError
    end
  end
end
