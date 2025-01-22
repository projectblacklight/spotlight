# frozen_string_literal: true

RSpec.describe Spotlight::Etl::Context do
  subject(:context) { described_class.new(resource, **context_args) }

  let(:resource) { instance_double(Spotlight::Resource, id: 123, document_model: SolrDocument) }
  let(:context_args) { {} }

  describe '#resource' do
    it 'extracts the Spotlight::Resource from the argument list' do
      expect(context.resource).to eq resource
    end
  end

  describe '#unique_key' do
    let(:data) { { id: '123' } }

    it 'tries to get a usable unique key for a transformed document' do
      expect(context.unique_key(data)).to eq '123'
    end
  end

  describe '#on_error' do
    context 'with a class-level handler' do
      let(:handler) { instance_double(Proc, call: nil) }

      it 'calls the class-level handler' do
        allow(described_class).to receive(:error_reporter).and_return(handler)

        subject.on_error(nil, nil, {})

        expect(handler).to have_received(:call)
      end
    end

    context 'with an instance-level handler' do
      let(:context_args) { { on_error: handler } }
      let(:handler) { instance_double(Proc, call: nil) }

      it 'calls the instance-level handler' do
        subject.on_error(nil, nil, {})

        expect(handler).to have_received(:call)
      end
    end

    context 'with :log' do
      it 'logs an error' do
        allow(Rails.logger).to receive(:error)

        subject.on_error(nil, nil, {})

        expect(Rails.logger).to have_received(:error).with(/Pipeline error/)
      end
    end

    context 'with :exception' do
      let(:context_args) { { on_error: :exception } }
      let(:e) { StandardError.new('asdf') }

      it 'raises an exception' do
        expect { subject.on_error(nil, e, {}) }.to raise_exception(e)
      end
    end
  end
end
