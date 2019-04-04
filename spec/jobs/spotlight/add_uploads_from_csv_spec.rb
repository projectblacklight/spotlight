# frozen_string_literal: true

describe Spotlight::AddUploadsFromCSV do
  subject(:job) { described_class.new(data, exhibit, user) }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
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
    upload = FactoryBot.create(:uploaded_resource)
    expect(Spotlight::Resources::Upload).to receive(:new).at_least(:once).and_return(upload)

    expect(upload).to receive(:build_upload).with(remote_image_url: 'x').and_call_original
    expect(upload).to receive(:build_upload).with(remote_image_url: 'y').and_call_original
    expect(upload).to receive(:save_and_index).at_least(:once)

    job.perform_now
  end
end
