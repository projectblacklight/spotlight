# frozen_string_literal: true

RSpec.describe Spotlight::Etl::Step do
  subject(:step) { described_class.new(definition, **step_args) }

  let(:definition) { ->(a = nil) { a || 'value' } }
  let(:step_args) { {} }

  describe '#call' do
    it 'returns the value from the defined step' do
      expect(step.call).to eq('value')
    end

    it 'passes through arguments' do
      expect(step.call('a')).to eq('a')
    end

    context 'with a class instance' do
      let(:definition) { Spotlight::Etl::SolrLoader.new }

      it 'runs the call method' do
        allow(definition).to receive(:call)

        step.call('a')

        expect(definition).to have_received(:call).with('a')
      end
    end

    context 'with a class' do
      let(:definition) { Spotlight::Etl::SolrLoader }
      let(:mock) { instance_double(definition, call: nil) }

      it 'runs the call method' do
        allow(definition).to receive(:new).and_return(mock)

        step.call('a', 'b')

        expect(mock).to have_received(:call).with('a', 'b')
      end

      it 'uses the same instance for the lifetime of the step' do
        allow(definition).to receive(:new).once.and_return(mock)

        step.call('a', 'b')
        step.call('a', 'b')

        expect(mock).to have_received(:call).twice.with('a', 'b')
      end
    end
  end

  describe '#finalize' do
    it 'does nothing if the definition does not have a #finalize method' do
      expect { step.finalize }.not_to raise_exception
    end

    context 'with a loader' do
      let(:definition) { Spotlight::Etl::SolrLoader.new }

      it 'runs the finalize method' do
        allow(definition).to receive(:finalize)

        step.finalize

        expect(definition).to have_received(:finalize)
      end
    end
  end
end
