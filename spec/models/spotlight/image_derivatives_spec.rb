require 'spec_helper'

class TestSpotlightImageDerivatives
  include Spotlight::ImageDerivatives
end

describe Spotlight::ImageDerivatives do
  let(:subject) { TestSpotlightImageDerivatives.new }
  describe '#spotlight_image_derivatives' do
    it 'includes default derivatives' do
      expect(subject.spotlight_image_derivatives.length).to eq 3
      expect(subject.spotlight_image_derivatives.map do |d|
        d[:field]
      end).to eq [Spotlight::Engine.config.full_image_field, Spotlight::Engine.config.thumbnail_field, Spotlight::Engine.config.square_image_field]
    end
  end
end
