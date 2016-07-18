describe Spotlight::Masthead, type: :model do
  describe '#display?' do
    let(:masthead) { stub_model(described_class) }
    let(:image) { OpenStruct.new }
    subject { masthead.display? }

    context 'when the masthead is set to not display' do
      it { is_expected.to be_falsey }
    end

    context 'when the cropped image is not present' do
      before { masthead.display = true }
      it { is_expected.to be_falsey }
    end

    context 'when the cropped image is present' do
      before do
        masthead.iiif_url = 'http://test.host/images/1/100,0,200,300/full/0/default.jpg'
      end

      context 'but the masthead is set to not display' do
        it { is_expected.to be_falsey }
      end

      context 'and the masthead is set to display' do
        before { masthead.display = true }
        it { is_expected.to be_truthy }
      end
    end
  end
end
