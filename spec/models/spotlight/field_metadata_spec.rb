require 'spec_helper'

describe Spotlight::FieldMetadata do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:repository) { double }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'a'
      config.add_facet_field 'b'
      config.add_facet_field 'c'
    end
  end

  let(:facet_response) do
    {
      facet_counts: {
        facet_fields: {
          a: { 'a' => 1, 'b' => 2, 'c' => 3 },
          b: { 'b' => 1 },
          c: { 7 => 1, 8 => 2, 9 => 3 }
        },

        facet_queries: {
          'a:[* TO *]' => 5,
          'b:[* TO *]' => 10,
          'c:[* TO *]' => 15
        }
      }
    }.with_indifferent_access
  end

  subject { described_class.new(exhibit, repository, blacklight_config) }

  before do
    allow(repository).to receive(:search).with(an_instance_of(SearchBuilder)).and_return(Blacklight::Solr::Response.new(facet_response, {}))
  end

  describe '#field' do
    it 'has a document count' do
      expect(subject.field('a')[:document_count]).to eq 5
      expect(subject.field('b')[:document_count]).to eq 10
      expect(subject.field('c')[:document_count]).to eq 15
    end

    it 'has a value count' do
      expect(subject.field('a')[:value_count]).to eq 3
      expect(subject.field('b')[:value_count]).to eq 1
      expect(subject.field('c')[:value_count]).to eq 3
    end

    it 'gets a list of top terms' do
      expect(subject.field('a')[:terms]).to match_array %w(a b c)
      expect(subject.field('b')[:terms]).to match_array %w(b)
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
