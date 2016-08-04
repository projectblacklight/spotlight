RSpec.describe Spotlight::ExhibitsHelper do
  describe '#card_image' do
    let(:exhibit) { FactoryGirl.create(:exhibit, :with_thumbnail) }
    subject { helper.card_image(exhibit) }
    it { is_expected.to eq 'https://exhibits-stage.stanford.edu/images/78/full/400,/0/default.jpg' }
  end
end
