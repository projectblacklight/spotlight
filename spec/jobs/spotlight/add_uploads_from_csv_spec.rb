describe Spotlight::AddUploadsFromCSV do
  subject(:job) { described_class.new(data, exhibit, user) }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:data) do
    [
      { 'url' => 'x' },
      { 'url' => 'y' }
    ]
  end

  let(:resource_x) { instance_double(Spotlight::Resource) }
  let(:resource_y) { instance_double(Spotlight::Resource) }

  before do
    allow(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
  end

  context 'with empty data' do
    let(:data) { [] }

    it 'sends the user an email after the indexing job is complete' do
      expect(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
      job.perform_now
    end
  end

  it 'creates uploaded resources for each row of data' do
    expect(Spotlight::Resources::Upload).to receive(:new).with(hash_including(remote_url_url: 'x')).and_return(resource_x)
    expect(Spotlight::Resources::Upload).to receive(:new).with(hash_including(remote_url_url: 'y')).and_return(resource_y)

    expect(resource_x).to receive(:save_and_index)
    expect(resource_y).to receive(:save_and_index)

    job.perform_now
  end
end
