# frozen_string_literal: true

describe Spotlight::ReindexJob do
  include ActiveJob::TestHelper

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:resource) { FactoryBot.create(:resource, exhibit:) }
  let(:user) { FactoryBot.create(:user) }

  before do
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
  end

  context 'with a resource' do
    subject { described_class.new(resource) }

    it 'attempts to reindex every resource in the exhibit' do
      expect(resource).to receive(:reindex)
      subject.perform_now
    end

    it 'adds some job tracking events' do
      expect { subject.perform_now }.to change(Spotlight::Event, :count).by(1)
    end
  end

  describe 'validity' do
    subject { described_class.new(resource, 'validity_token' => 'xyz') }

    let(:mock_checker) { instance_double(Spotlight::ValidityChecker) }

    before do
      allow(described_class).to receive(:validity_checker).and_return(mock_checker)
      allow(mock_checker).to receive(:mint).with(anything).and_return('xyz')
      ActiveJob::Base.queue_adapter = :test
    end

    after { ActiveJob::Base.queue_adapter = :inline }

    it 'mints a new validity token' do
      expect { described_class.perform_later(resource) }.to have_enqueued_job(described_class).with(resource, 'validity_token' => 'xyz')
    end

    it 'does nothing if the token is no longer valid' do
      allow(mock_checker).to receive(:check).with(subject, validity_token: 'xyz').and_return(false)
      expect(resource).not_to receive(:reindex)

      subject.perform_now
    end

    it 'indexes the resource if the token is valid' do
      allow(mock_checker).to receive(:check).with(subject, validity_token: 'xyz').and_return(true)
      expect(resource).to receive(:reindex)

      subject.perform_now
    end
  end

  context 'with start and finish' do
    it 'indexes the resources within that page' do
      count = 0
      allow_any_instance_of(Spotlight::Resource).to receive(:reindex) do
        count += 1
      end

      described_class.perform_now(exhibit, start: 0, finish: resource.id)

      expect(count).to eq 1
    end

    it 'does not index resources off that page' do
      count = 0
      allow_any_instance_of(Spotlight::Resource).to receive(:reindex) do
        count += 1
      end

      described_class.perform_now(exhibit, start: resource.id + 1, finish: resource.id + 500)

      expect(count).to eq 0
    end
  end
end
