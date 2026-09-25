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
      expect(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
      job.perform_now
    end
  end

  it 'creates uploaded resources for each row of data' do
    upload = FactoryBot.create(:uploaded_resource)
    expect(Spotlight::Resources::Upload).to receive(:new).exactly(3).times.and_return(upload)

    expect(upload).to receive(:build_upload).with(remote_image_url: 'x').and_call_original
    expect(upload).to receive(:build_upload).with(remote_image_url: 'y').and_call_original
    expect(upload).not_to receive(:build_upload).with(remote_image_url: '~')
    expect(upload).to receive(:save_and_index).at_least(:once)

    job.perform_now
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

  context 'with pipe-delimited values' do
    before do
      FactoryBot.create(:custom_field, exhibit:, slug: 'custom_field', is_multiple: true)
      FactoryBot.create(:custom_field, exhibit:, slug: 'custom_field_2', is_multiple: false)
    end

    let(:data) do
      [
        { 'url' => 'x', 'custom_field' => 'a|b|c', 'custom_field_2' => 'hello | world', 'custom_field_3' => '' }
      ]
    end

    it 'splits into arrays' do
      expect(job.send(:processed_csv, data, exhibit)).to eq(
        [{
          'url' => 'x',
          'custom_field' => %w[a b c],
          'custom_field_2' => 'hello | world'
        }]
      )
    end
  end
end
