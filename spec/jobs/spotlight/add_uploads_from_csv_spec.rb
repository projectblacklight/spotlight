# frozen_string_literal: true

RSpec.describe Spotlight::AddUploadsFromCsv do
  subject(:job) { described_class.new(data, exhibit, user) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:data) do
    [
      { 'url' => 'x' },
      { 'url' => 'y' },
      { 'url' => '~' }
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
      allow(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
      job.perform_now
      expect(Spotlight::IndexingCompleteMailer).to have_received(:documents_indexed)
    end
  end

  it 'creates uploaded resources for each row of data' do
    upload = FactoryBot.create(:uploaded_resource)
    allow(Spotlight::Resources::Upload).to receive(:new).and_return(upload)
    allow(upload).to receive(:build_upload).and_call_original
    allow(upload).to receive(:save_and_index)

    job.perform_now

    expect(Spotlight::Resources::Upload).to have_received(:new).exactly(3).times
    expect(upload).to have_received(:build_upload).with(remote_image_url: 'x')
    expect(upload).to have_received(:build_upload).with(remote_image_url: 'y')
    expect(upload).not_to have_received(:build_upload).with(remote_image_url: '~')
    expect(upload).to have_received(:save_and_index).at_least(:once)
  end

  context 'with errors' do
    it 'collects errors uploaded resources for each row of data' do
      allow(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
      job.perform_now
      expect(Spotlight::IndexingCompleteMailer).to have_received(:documents_indexed).with(
        data, exhibit, user,
        indexed_count: 1,
        errors: {
          1 => array_including(match(Regexp.union(/relative URI: x/, /URI scheme '' not in whitelist:/))),
          2 => array_including(include('Upload is invalid'))
        }
      )
    end
  end
end
