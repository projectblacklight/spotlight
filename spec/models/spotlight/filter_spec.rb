require 'spec_helper'

describe Spotlight::Filter do
  context 'with a simple string field' do
    subject { described_class.new(field: 'x', value: 'y') }

    it 'passes the value through' do
      expect(subject.to_hash).to eq 'x' => 'y'
    end
  end

  context 'with a boolean field' do
    subject { described_class.new(field: 'x_bsi', value: 'true') }

    it 'casts the value to a boolean' do
      expect(subject.to_hash).to eq 'x_bsi' => true
    end
  end
end
