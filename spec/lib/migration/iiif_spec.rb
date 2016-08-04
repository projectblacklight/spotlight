require 'migration/iiif'

RSpec.describe Migration::IIIF do
  let(:instance) { described_class.new('http://test.host') }
  describe '#iiif_url' do
    subject { instance.iiif_url(image) }
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

  describe '#migrate_contact_avatars' do
    let(:file) { double }
    let(:contact1) { Spotlight::Contact.create }
    let(:contact2) { Spotlight::Contact.create }
    before do
      allow(File).to receive(:new).and_return(file)
      allow(contact1).to receive('read_attribute_before_type_cast').and_call_original
      allow(contact2).to receive('read_attribute_before_type_cast').and_call_original
      allow(contact1).to receive('read_attribute_before_type_cast').with('avatar').and_return('file1.jpg')
      allow(contact2).to receive('read_attribute_before_type_cast').with('avatar').and_return('file2.jpg')
    end
    it 'migrates' do
      expect do
        instance.send :migrate_contact_avatars
      end.to change { Spotlight::FeaturedImage.count }.by(2)
      expect(Spotlight::Contact.all.pluck(:avatar_id)).to eq Spotlight::FeaturedImage.all.pluck(:id)
    end
  end
end
