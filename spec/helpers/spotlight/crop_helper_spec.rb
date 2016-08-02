describe Spotlight::CropHelper do
  describe '.contact_crop' do
    let(:template) { double }
    let(:form) { double(draw: true) }
    it 'has initial_set_select' do
      expect(Spotlight::IIIFCropper).to receive(:new).with(template, :avatar, 70, 70).and_return(form)
      helper.contact_crop(template, :avatar)
    end
  end
end
