describe Spotlight::CropHelper do
  describe '.site_thumbnail_crop_options' do
    it 'has initial_set_select' do
      expect(helper.site_thumbnail_crop_options[:initial_set_select]).to eq [0, 0, 400, 400]
    end
  end
end
