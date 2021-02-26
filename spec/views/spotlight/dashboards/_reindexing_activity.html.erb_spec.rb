# frozen_string_literal: true

describe 'spotlight/dashboards/_reindexing_activity.html.erb', type: :view do
  let(:p) { 'spotlight/dashboards/reindexing_activity' }
  let(:exhibit) { FactoryBot.build(:exhibit) }

  before do
    assign(:recent_reindexing, recent_reindexing)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  context 'the reindexing log is empty' do
    let(:recent_reindexing) { [] }

    before do
      render p
    end

    it 'displays the section header' do
      expect(rendered).to have_css('h2', text: 'Recent item indexing activity')
    end

    it 'displays an explanatory message when there are no reindexing attempts in the log' do
      expect(rendered).to have_content 'There has been no reindexing activity'
    end
  end

  context 'the reindexing log has entries' do
    # recent reindexing entries should be sorted by start_time in descending order, so mock that behavior
    let(:recent_reindexing) do
      [
        FactoryBot.build(:job_tracker, status: 'enqueued'),
        FactoryBot.build(:job_tracker, status: 'completed', data: { progress: 10 }),
        FactoryBot.build(:job_tracker, status: 'in_progress', created_at: Time.zone.parse('January 10, 2017 23:00')),
        FactoryBot.build(:job_tracker, status: 'completed', data: { progress: 100 }),
        FactoryBot.build(:job_tracker, status: 'failed', data: { progress: 10 })
      ]
    end

    before do
      render p
    end

    it 'displays the correct localized column headings when there are reindexing attempts in the log' do
      expect(rendered).to have_css('table.table-striped th.col-3', text: 'Date', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-3', text: 'Requested by', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-1', text: 'Items indexed', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-3', text: 'Elapsed time', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-2', text: 'Status', count: 1)
    end

    it 'formats the start time correctly' do
      expect(rendered).to have_css('table.table-striped td', text: 'January 05, 2017 23:00', count: 4)
      expect(rendered).to have_css('table.table-striped td', text: 'January 10, 2017 23:00', count: 1)
    end

    it 'displays the user that initiated the reindexing' do
      expect(rendered).to have_css('table.table-striped td', text: /user\d+@example.com/, count: 5)
    end

    it 'displays the count of reindexed items' do
      expect(rendered).to have_css('table.table-striped td', text: /^10$/, count: 2)
      expect(rendered).to have_css('table.table-striped td', text: /^100$/, count: 1)
    end

    it 'displays the duration of completed reindexing attempts' do
      expect(rendered).to have_css('table.table-striped td', text: '5 minutes', count: 3)
    end

    it 'displays the status of the reindexing attempt using localized text' do
      expect(rendered).to have_css('table.table-striped td', text: 'Not yet started', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Successful', count: 2)
      expect(rendered).to have_css('table.table-striped td', text: 'In progress', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Failed', count: 1)
    end
  end

  context 'a reindexing log entry has a null user' do
    let(:recent_reindexing) do
      [FactoryBot.build(:job_tracker, status: 'completed', data: { progress: 10 }, user: nil)]
    end

    it 'displays blank in the user field and renders without error' do
      expect { render p }.not_to raise_error

      # we expect one blank table cell for the user, and values for everything else
      expect(rendered).to have_css('table.table-striped td', text: /^$/, count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'January 05, 2017 23:00', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: /^10$/, count: 1)
      expect(rendered).to have_css('table.table-striped td', text: '5 minutes', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Successful', count: 1)
    end
  end
end
