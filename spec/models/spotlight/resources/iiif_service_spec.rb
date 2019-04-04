# frozen_string_literal: true

require 'spec_helper'

describe Spotlight::Resources::IiifService do
  let(:url) { 'uri://for-top-level-collection' }
  subject { described_class.new(url) }
  before { stub_default_collection }

  describe '#collections' do
    it 'returns service objects for each top-level collection' do
      expect(subject.collections.length).to eq 2
      expect(subject.collections).to be_all { |s| s.is_a?(described_class) }
    end

    it 'returns service objects for nested collections' do
      expect(subject.collections.first.collections.length).to eq 1
      expect(subject.collections.last.collections).to be_blank
      expect(subject.collections.first.collections.first).to be_a(described_class)
      expect(
        subject.collections.first.collections.first.collections
      ).to be_blank
    end
  end

  describe '#manifests' do
    it 'returns manifests for the current service level' do
      expect(subject.manifests.length).to eq 2
      expect(subject.manifests.first).to be_a Spotlight::Resources::IiifManifest
      expect(subject.collections.first.manifests.length).to eq 2
      expect(
        subject.collections.first.manifests.first
      ).to be_a Spotlight::Resources::IiifManifest
    end
  end

  describe '#parse' do
    let(:manifests) { described_class.parse(url) }

    it 'recursively traverses all all the collections and returns manifests' do
      expect(manifests).to be_all do |manifest|
        manifest.is_a?(Spotlight::Resources::IiifManifest)
      end
    end

    it 'returns manifests representing collection documents' do
      expect(manifests.count).to eq 8
    end
    it 'keeps track of the parent collection' do
      arr = manifests.to_a
      expect(arr[1].collection).to eq arr[0]
    end
  end
end
