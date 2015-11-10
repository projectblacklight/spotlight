require 'spec_helper'

describe Spotlight::ResourceProvider do
  describe '.for_resource' do
    let(:thing) { double }
    let(:type_a) { double('TypeA', weight: 10) }
    let(:type_b) { double('TypeB', weight: 5) }
    let(:providers) { [type_a, type_b] }
    subject { described_class.for_resource(thing) }

    before do
      allow(described_class).to receive_messages(providers: providers)
    end

    it 'returns a class that can provide indexing for the resource' do
      expect(type_a).to receive(:can_provide?).with(thing).and_return(true)
      expect(type_b).to receive(:can_provide?).with(thing).and_return(false)
      expect(subject).to eq type_a
    end

    it 'returns the lowest weighted class that can provide indexing for the resource' do
      expect(type_a).to receive(:can_provide?).with(thing).and_return(true)
      expect(type_b).to receive(:can_provide?).with(thing).and_return(true)
      expect(subject).to eq type_b
    end
  end
end
