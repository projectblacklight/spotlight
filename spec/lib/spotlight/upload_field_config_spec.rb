# frozen_string_literal: true

RSpec.describe Spotlight::UploadFieldConfig do
  describe '#label' do
    it 'accepts a proc and calls it' do
      label = -> { 'returned string' }
      expect(described_class.new(field_name: 'something', label:).label).to eq 'returned string'
    end

    it 'returns any non-proc value' do
      expect(described_class.new(field_name: 'something', label: 'String').label).to eq 'String'
    end

    it 'falls back to the field name when no label is given' do
      expect(described_class.new(field_name: 'something').label).to eq 'something'
    end
  end

  describe '#solr_field' do
    it 'is an alias of the #solr_field method so it can be polymorphic with other Blacklight configurations' do
      expect(described_class.new(field_name: 'something').solr_field).to eq 'something'
    end
  end

  describe '#solr_fields' do
    it 'is backwards compatible with the old way of configuring fields' do
      expect(described_class.new(field_name: 'something').solr_fields).to eq ['something']
    end
  end

  describe '#data_to_solr' do
    it 'returns a hash of the various solr fields mapped to the provided value' do
      expect(described_class.new(field_name: 'something', solr_fields: %w[a b]).data_to_solr('value')).to eq 'a' => 'value', 'b' => 'value'
    end

    it 'supports configuring a lambda to pre-process data for a field' do
      expect(described_class.new(field_name: 'something', solr_fields: [int_field: ->(value) { value.to_i }]).data_to_solr('123value')).to eq int_field: 123
    end
  end
end
