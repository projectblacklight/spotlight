require 'spec_helper'

RSpec.describe SirTrevorRails::Block do
  describe '.block_class' do
    subject { Block }

    describe 'for known type' do
      let(:klass) { subject.block_class('tweet') }

      it 'returns class' do
        expect { klass == Blocks::TweetBlock }
      end

      it 'returned class is the one defined in file' do
        expect { klass.method_defined? :at_name }
      end
    end

    describe 'for unknown type' do
      let(:klass) { subject.block_class('unknown') }

      it 'defines and returns class' do
        expect { klass == Blocks::UnknownBlock }
      end

      it 'defines class that inherits from Block' do
        expect { klass.superclass == Block }
      end
    end
  end

  describe '.from_hash' do
    let(:source_hash) { { type: 'test', data: {} } }
    let(:block) { Block.from_hash(source_hash, nil) }

    it 'initializes new block based on type field' do
      expect { block.is_a? Blocks::TestBlock }
    end

    it 'creates accessors for all fields defined in data field' do
      source_hash[:data].merge!(width: '100')

      expect { block.width == '100' }
    end
  end

  describe 'JSON representation' do
    let(:empty_source_hash) { { type: 'test', data: {} } }
    let(:empty_block) { Block.from_hash(empty_source_hash, nil) }
    let(:data_source_hash) { { type: 'test', data: { one: 2, three: 4 } } }
    let(:data_block) { Block.from_hash(data_source_hash, nil) }

    it 'returns source hash when #as_json is called' do
      expect { empty_block.as_json == empty_source_hash }
    end

    it 'serializes block data' do
      expect { data_block.as_json == data_source_hash }
    end
  end

  describe 'partial view lookup' do
    let(:source_hash) { { type: 'test', data: {} } }
    let(:block) { Block.from_hash(source_hash, nil) }

    it 'uses block type to find view paritals' do
      expect { block.to_partial_path == 'sir_trevor/blocks/test_block' }
    end
  end
end
