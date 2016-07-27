describe Spotlight::ReindexProgress, type: :model do
  let(:start_time) { 20.minutes.ago.at_beginning_of_minute }
  let(:finish_time) { 5.minutes.ago.at_beginning_of_minute }
  let(:updated_time) { 1.minute.ago.at_beginning_of_minute }
  let!(:first_resource) do
    FactoryGirl.create(
      :resource,
      updated_at: updated_time,
      indexed_at: start_time,
      enqueued_at: start_time,
      last_indexed_finished: start_time,
      last_indexed_estimate: 7,
      last_indexed_count: 5,
      index_status: 1
    )
  end
  let!(:last_resource) do
    FactoryGirl.create(
      :resource,
      updated_at: finish_time,
      indexed_at: finish_time,
      enqueued_at: start_time,
      last_indexed_finished: finish_time,
      last_indexed_estimate: 3,
      last_indexed_count: 2,
      index_status: 1
    )
  end
  let(:resources) { [first_resource, last_resource] }
  subject { described_class.new(Spotlight::Resource.all) }
  let(:json) { JSON.parse(subject.to_json) }

  before do
    allow(subject).to receive_messages(completed_resources: resources)
  end

  describe '#recently_in_progress?' do
    context 'when the last resource has been updated within the allotted time' do
      it 'is true' do
        expect(subject).to be_recently_in_progress
      end
    end

    context 'when any of the resources is makred as waiting' do
      before do
        first_resource.waiting!
      end
      it 'is true' do
        expect(subject).to be_recently_in_progress
      end
    end

    context 'when the last resources has been updated outside of the allotted time ' do
      before do
        expect(last_resource).to receive_messages(last_indexed_finished: 12.minutes.ago)
      end
      it 'is false' do
        expect(subject).not_to be_recently_in_progress
      end
    end

    it 'is included in the json' do
      expect(json['recently_in_progress']).to be true
    end
  end

  describe '#started_at' do
    it 'returns the indexed_at attribute of the first resource' do
      expect(subject.started_at).to eq start_time
    end

    it 'is included in the json as a localized string' do
      expect(json['started_at']).to eq I18n.l(start_time, format: :short)
    end
  end

  describe '#updated_at' do
    it 'returns the updated_at attribute of the last resource' do
      expect(subject.updated_at).to eq updated_time
    end

    it 'is included in the json as a localized string under the updated_at attribute' do
      expect(json['updated_at']).to eq I18n.l(updated_time, format: :short)
    end
  end

  describe '#finished_at' do
    it 'returns the updated_at attribute of the last resource' do
      expect(subject.finished_at).to eq finish_time
    end

    it 'is included in the json as a localized string under the updated_at attribute' do
      expect(json['finished_at']).to eq I18n.l(finish_time, format: :short)
    end
  end

  describe '#total' do
    it 'sums the resources last_indexed_estimate' do
      expect(subject.total).to eq 10
    end

    it 'is included in the json' do
      expect(json['total']).to eq 10
    end
  end

  describe '#completed' do
    it 'sums the resources last_indexed_count' do
      expect(subject.completed).to eq 7
    end

    it 'is included in the json' do
      expect(json['completed']).to eq 7
    end
  end
end
