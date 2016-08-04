require 'migration/iiif'

RSpec.describe Migration::IIIF do
  describe '.iiif_url' do
    subject { described_class.iiif_url('http://test.host', image) }
    let(:image) do
      instance_double klass, id: '123',
                             image_crop_x: '100',
                             image_crop_y: '200',
                             image_crop_w: '250',
                             image_crop_h: '275'
    end
    context "when it's a masthead" do
      before do
        allow(image).to receive(:is_a?).with(Spotlight::Masthead).and_return(true)
      end
      let(:klass) { Spotlight::Masthead }
      it { is_expected.to eq 'http://test.host/images/123/100,200,250,275/1440,/0/default.jpg' }
    end

    context "when it's not a masthead" do
      before do
        allow(image).to receive(:is_a?).with(Spotlight::Masthead).and_return(false)
      end
      let(:klass) { Spotlight::FeaturedImage }
      it { is_expected.to eq 'http://test.host/images/123/100,200,250,275/250,275/0/default.jpg' }
    end
  end
end
