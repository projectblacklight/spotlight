require 'spec_helper'
require 'carrierwave/test/matchers'

describe Spotlight::ItemUploader do
  include CarrierWave::Test::Matchers
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:resource) { stub_model(Spotlight::Resources::Upload) }
  before do
    allow(resource).to receive(:exhibit).and_return(exhibit)
    described_class.enable_processing = true
  end
  after do
    described_class.enable_processing = false
  end
  describe 'default configuration' do
    subject do
      described_class.new(resource, :resource)
    end

    before do
      subject.store!(File.open(File.expand_path(File.join('..', 'spec', 'fixtures', '800x600.png'), Rails.root)))
    end

    after do
      subject.remove!
    end

    context 'the thumb version' do
      it 'scales down an image so that the longest edge is 400px (maintaining aspect ratio)' do
        expect(subject.thumb).to have_dimensions(400, 300)
      end
    end

    context 'the square version' do
      it 'scales down a landscape image to fit within 100px by 100px' do
        expect(subject.square).to be_no_larger_than(100, 100)
      end
    end
  end
  describe 'with added configurations' do
    subject do
      described_class.new(resource, :resource)
    end

    before do
      Spotlight::ImageDerivatives.spotlight_image_derivatives << {
        version: :super_tiny,
        blacklight_config_field: :super_tiny_field,
        lambda: lambda do
          version :super_tiny do
            process resize_to_fill: [25, 25]
          end
        end
      }
      subject.store!(File.open(File.expand_path(File.join('..', 'spec', 'fixtures', '800x600.png'), Rails.root)))
    end

    after do
      subject.remove!
    end

    context 'the newly configured version' do
      pending 'should have the newly configured dimensions' do
        expect(subject.super_tiny).to have_dimensions(25, 25)
      end
    end
  end
end
