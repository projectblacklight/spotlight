# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SirTrevorRails::Block do
  describe '.block_class' do
    subject { described_class }

    describe 'for known type' do
      let(:klass) { subject.block_class('browse') }

      it 'returns class' do
        expect(klass).to eq SirTrevorRails::Blocks::BrowseBlock
      end

      it 'returned class is the one defined in file' do
        expect(klass.method_defined?(:searches)).to be true
      end
    end

    describe 'for unknown type' do
      let(:klass) { subject.block_class('unknown') }

      it 'defines and returns class' do
        expect(klass).to eq SirTrevorRails::Blocks::UnknownBlock
      end

      it 'defines class that inherits from Block' do
        expect(klass.superclass).to eq described_class
      end
    end
  end

  describe '.from_hash' do
    let(:source_hash) { { type: 'test', data: {} } }
    let(:block) { described_class.from_hash(source_hash, nil) }

    it 'initializes new block based on type field' do
      expect(block).to be_a_kind_of SirTrevorRails::Blocks::TestBlock
    end

    it 'creates accessors for all fields defined in data field' do
      source_hash[:data].merge!(width: '100')

      expect(block.width).to eq '100'
    end
  end

  describe 'JSON representation' do
    let(:empty_source_hash) { { type: 'test', data: {} } }
    let(:empty_block) { described_class.from_hash(empty_source_hash, nil) }
    let(:data_source_hash) { { type: 'test', data: { one: 2, three: 4 } } }
    let(:data_block) { described_class.from_hash(data_source_hash, nil) }

    it 'returns source hash when #as_json is called' do
      expect(empty_block.as_json).to eq empty_source_hash
    end

    it 'serializes block data' do
      expect(data_block.as_json).to eq data_source_hash
    end
  end

  describe 'partial view lookup' do
    let(:source_hash) { { type: 'test', data: {} } }
    let(:block) { described_class.from_hash(source_hash, nil) }

    it 'uses block type to find view paritals' do
      expect(block.to_partial_path).to eq 'sir_trevor/blocks/test_block'
    end
  end
end
