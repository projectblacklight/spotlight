# frozen_string_literal: true

describe Spotlight::Etl::Executor do
  subject(:executor) { described_class.new(pipeline, context) }

  let(:pipeline) do
    Spotlight::Etl::Pipeline.new do |pipeline|
      pipeline.sources = [Spotlight::Etl::Sources::IdentitySource]
      pipeline.transforms = [Spotlight::Etl::Transforms::IdentityTransform]
      pipeline.loaders = [->(result, *) { arr << result }]
    end
  end
  let(:context) { Spotlight::Etl::Context.new(resource) }
  let(:resource) { Spotlight::Resource.new }
  let(:arr) { [] }

  describe '#call' do
    it 'provides the context to the sources' do
      pipeline.sources = [->(context, *) { [{ context: context }] }]

      executor.call

      expect(arr).to eq [{ context: context }]
    end

    it 'makes the current source available to transforms' do
      pipeline.transforms = [->(_data, pipeline) { pipeline.source }]

      executor.call

      expect(arr).to eq [resource]
    end

    it 'chains the calls to the transforms' do
      pipeline.transforms = [
        ->(data, *) { data.merge(a: 1) },
        ->(data, *) { data.merge(b: 2) },
        ->(data, *) { data.merge(c: 3) }
      ]

      executor.call

      expect(arr).to eq [{ a: 1, b: 2, c: 3 }]
    end

    it 'caches the step instances across sources' do
      pipeline.sources = [->(*) { [1, 2, 3] }]

      pipeline.transforms = [
        Class.new do
          def initialize
            @sum = 0
          end

          def call(data, pipeline)
            @sum += pipeline.source

            data.merge(sum: @sum)
          end
        end
      ]

      executor.call

      expect(arr).to eq [{ sum: 1 }, { sum: 3 }, { sum: 6 }]
    end

    it 'loads resulting documents' do
      loader = Spotlight::Etl::SolrLoader.new
      pipeline.sources = [->(*) { [{}, {}, {}] }]
      pipeline.loaders = [loader]

      allow(loader).to receive(:call)

      executor.call

      expect(loader).to have_received(:call).exactly(3).times
    end

    it 'allows steps to throw :skip to skip the current source' do
      pipeline.pre_processes = [
        ->(*) { throw(:skip) }
      ]

      executor.call

      expect(arr).to be_blank
    end

    it 'forwards errors to the context error handler' do
      e = StandardError.new
      pipeline.transforms = [->(*) { raise e }]

      allow(context).to receive(:on_error)
      executor.call

      expect(context).to have_received(:on_error).with(executor, e, {})
    end

    context 'after processing the data' do
      it 'calls finalize on the loaders' do
        loader = Spotlight::Etl::SolrLoader.new
        pipeline.sources = [->(*) { [{}, {}, {}] }]
        pipeline.loaders = [loader]

        allow(loader).to receive(:call)
        allow(loader).to receive(:finalize)

        executor.call

        expect(loader).to have_received(:call).exactly(3).times
        expect(loader).to have_received(:finalize).once
      end

      it 'resets the step cache' do
        pipeline.transforms = [
          Class.new do
            def initialize
              @count = 0
            end

            def call(data, *)
              @count += 1

              data.merge(count: @count)
            end
          end
        ]

        executor.call
        executor.call

        expect(arr).to eq [{ count: 1 }, { count: 1 }]
      end
    end
  end

  describe '#estimated_size' do
    let(:source) { ->(*) { [1, 2, 3, 4] } }

    before do
      pipeline.sources = [source]
    end

    it 'estimates the final size from the sources' do
      expect(executor.estimated_size).to eq 4
    end
  end
end
