require 'spec_helper'

describe Spotlight::FieldMetadata do
  let(:repository) { double }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'a'
      config.add_facet_field 'b'
      config.add_facet_field 'c'
    end
  end

  let(:luke_response) do
    {
      fields: {
        a: {
          distinct: 100,
          topTerms: %w(q w e)
        },
        b: {
          distinct: 50,
          topTerms: %w(r t y)
        },
        c: {
          distinct: 3,
          topTerms: [7, 8, 9]
        }
      }
    }.with_indifferent_access
  end

  let(:facet_response) do
    {
      facet_counts: {
        facet_queries: {
          'a:[* TO *]' => 5,
          'b:[* TO *]' => 10,
          'c:[* TO *]' => 15
        }
      }
    }.with_indifferent_access
  end

  subject { described_class.new(repository, blacklight_config) }

  before do
    allow(repository).to receive(:send_and_receive).with('admin/luke', hash_including(fl: '*')).and_return(luke_response)
    allow(repository).to receive(:search).with(hash_including('facet' => true)).and_return(facet_response)
  end

  describe '#field' do
    it 'has a document count' do
      expect(subject.field('a')[:document_count]).to eq 5
      expect(subject.field('b')[:document_count]).to eq 10
      expect(subject.field('c')[:document_count]).to eq 15
    end

    it 'has a value count' do
      expect(subject.field('a')[:value_count]).to eq 100
      expect(subject.field('b')[:value_count]).to eq 50
      expect(subject.field('c')[:value_count]).to eq 3
    end

    it 'gets a list of top terms' do
      expect(subject.field('a')[:terms]).to match_array %w(q w e)
      expect(subject.field('b')[:terms]).to match_array %w(r t y)
      expect(subject.field('c')[:terms]).to match_array [7, 8, 9]
    end

    context 'for a missing field' do
      it 'has reasonable default values' do
        expect(subject.field('d')[:document_count]).to eq 0
        expect(subject.field('d')[:value_count]).to eq 0
        expect(subject.field('d')[:terms]).to be_empty
      end
    end
  end
end
