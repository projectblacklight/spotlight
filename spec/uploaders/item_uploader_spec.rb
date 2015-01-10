require 'spec_helper'
require 'carrierwave/test/matchers'

describe Spotlight::ItemUploader do
  include CarrierWave::Test::Matchers
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:resource) { stub_model(Spotlight::Resources::Upload) }
  before do
    allow(resource).to receive(:exhibit).and_return(exhibit)
    Spotlight::ItemUploader.enable_processing = true
  end
  after do
    Spotlight::ItemUploader.enable_processing = false
  end
  describe 'default configuration' do
    before do
      @uploader = Spotlight::ItemUploader.new(resource, :resource)
      @uploader.store!(File.open(File.expand_path(File.join('..', 'fixtures', '800x600.png'), Rails.root)))
    end

    after do
      @uploader.remove!
    end

    context 'the thumb version' do
      it "should scale down an image so that the longest edge is 400px (maintaining aspect ratio)" do
        expect(@uploader.thumb).to have_dimensions(400, 300)
      end
    end

    context 'the square version' do
      it "should scale down a landscape image to fit within 100px by 100px" do
        expect(@uploader.square).to be_no_larger_than(100, 100)
      end
    end
  end
  describe 'with added configurations' do
    before do
      Spotlight::ItemUploader.configured_versions << {
        version: :super_tiny,
        blacklight_config_field: :super_tiny_field,
        lambda: lambda {
          version :super_tiny do
            process :resize_to_fill => [25,25]
          end
        }
      }
      @uploader = Spotlight::ItemUploader.new(resource, :resource)
      @uploader.store!(File.open(File.expand_path(File.join('..', 'fixtures', '800x600.png'), Rails.root)))
    end

    after do
      @uploader.remove!
    end

    context 'the newly configured version' do
      pending "should have the newly configured dimensions" do
        expect(@uploader.super_tiny).to have_dimensions(25, 25)
      end
    end
  end
end