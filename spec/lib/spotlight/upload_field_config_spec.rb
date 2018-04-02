# frozen_string_literal: true

RSpec.describe Spotlight::UploadFieldConfig do
  describe '#label' do
    it 'accepts a proc and calls it' do
      label = -> { 'returned string' }
      expect(described_class.new(field_name: 'something', label: label).label).to eq 'returned string'
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
end
