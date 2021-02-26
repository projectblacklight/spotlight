# frozen_string_literal: true

describe 'spotlight/job_trackers/show', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:job_tracker) { FactoryBot.create(:job_tracker, job_class: 'Spotlight::ReindexExhibitJob', on: exhibit, user: user) }
  let(:user) { FactoryBot.create(:user) }

  before do
    assign(:exhibit, exhibit)
    assign(:job_tracker, job_tracker)

    allow(view).to receive_messages(current_exhibit: exhibit)
  end

  it 'displays the type of job' do
    render
    expect(rendered).to have_selector 'h2', text: 'Spotlight::ReindexExhibitJob'
  end

  it 'displays the job status for enqueued jobs' do
    job_tracker.update(status: 'enqueued')
    render
    expect(rendered).to have_content '⏱'
  end

  it 'displays the job status for failed jobs' do
    job_tracker.update(status: 'failed')
    render
    expect(rendered).to have_content '🟥'
    expect(rendered).to have_content 'job failed'
  end

  it 'displays the job status for successful jobs' do
    job_tracker.update(status: 'completed')
    render
    expect(rendered).to have_content '✅'
    expect(rendered).to have_content 'job completed'
  end

  it 'display job started events' do
    render
    expect(rendered).to have_selector 'tr', text: '1 job started', normalize_ws: true
  end

  it 'records who started the job' do
    render
    expect(rendered).to have_selector 'tr', text: "2 job created by #{user.email}", normalize_ws: true
  end

  it 'displays logged messages' do
    job_tracker.events.create(data: { message: 'this is a useful log message' })
    job_tracker.events.create(data: { message: 'and so is this' })

    render
    expect(rendered).to have_selector 'tr', text: 'this is a useful log message'
    expect(rendered).to have_selector 'tr', text: 'and so is this'
  end

  it 'displays job progress information' do
    allow(job_tracker).to receive_messages(progress: 37, total: 51)

    render
    expect(rendered).to have_content 'processed 37 / 51'
  end
end
