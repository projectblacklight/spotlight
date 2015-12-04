require 'spec_helper'

describe Spotlight::JcropHelper do
  describe '.default_thumbnail_jcrop_options' do
    it 'produces a 4:3 aspect ratio by default' do
      expect(helper.default_thumbnail_jcrop_options[:aspect_ratio]).to eq 4.0 / 3.0
    end

    context 'with a custom thumbnail size' do
      before do
        allow(Spotlight::Engine.config).to receive(:featured_image_thumb_size).and_return([7, 5])
      end

      it 'produces a 7:5 aspect ratio' do
        expect(helper.default_thumbnail_jcrop_options[:aspect_ratio]).to eq 7.0 / 5.0
      end
    end
  end

  describe '.default_site_thumbnail_jcrop_options' do
    it 'produces a 1:1 aspect ratio by default' do
      expect(helper.default_site_thumbnail_jcrop_options[:aspect_ratio]).to eq 1
    end

    context 'with a custom square thumbnail size' do
      before do
        allow(Spotlight::Engine.config).to receive(:featured_image_square_size).and_return([3, 2])
      end

      it 'produces a 3:2 aspect ratio' do
        expect(helper.default_site_thumbnail_jcrop_options[:aspect_ratio]).to eq 3.0 / 2.0
      end
    end
  end
end
