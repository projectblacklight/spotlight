# frozen_string_literal: true

describe Spotlight::Etl::Pipeline do
  let(:mock_executor) { instance_double(Spotlight::Etl::Executor, call: 'result', estimated_size: 10) }
  let(:context) { instance_double(Spotlight::Etl::Context) }

  describe '#call' do
    it 'forwards the call to the executor' do
      allow(Spotlight::Etl::Executor).to receive(:new).with(subject, context, cache: nil).and_return(mock_executor)

      expect(subject.call(context)).to eq 'result'
    end
  end

  describe '#estimated_size' do
    it 'forwards the call to the executor' do
      allow(Spotlight::Etl::Executor).to receive(:new).with(subject, context, any_args).and_return(mock_executor)

      expect(subject.estimated_size(context)).to eq 10
    end
  end
end
