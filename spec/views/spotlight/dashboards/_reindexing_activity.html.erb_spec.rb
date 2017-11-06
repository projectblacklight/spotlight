describe 'spotlight/dashboards/_reindexing_activity.html.erb', type: :view do
  # recent reindexing entries should be sorted by start_time in descending order, so mock that behavior
  let(:recent_reindexing) do
    [FactoryBot.build(:unstarted_reindexing_log_entry)] + # nil start_time is trouble for the sort_by used to create the rest of the fixture's rows
      [
        FactoryBot.build(:reindexing_log_entry),
        FactoryBot.build(:in_progress_reindexing_log_entry),
        FactoryBot.build(:recent_reindexing_log_entry),
        FactoryBot.build(:failed_reindexing_log_entry)
      ].sort_by(&:start_time).reverse
  end
  let(:p) { 'spotlight/dashboards/reindexing_activity' }

  context 'the reindexing log is empty' do
    before do
      assign(:recent_reindexing, [])
      render p
    end

    it 'displays the section header' do
      expect(rendered).to have_css('h3', text: 'Recent Item Indexing Activity')
    end

    it 'displays an explanatory message when there are no reindexing attempts in the log' do
      expect(rendered).to have_content 'There has been no reindexing activity'
    end
  end

  context 'the reindexing log has entries' do
    before do
      assign(:recent_reindexing, recent_reindexing)
      render p
    end

    it 'displays the correct localized column headings when there are reindexing attempts in the log' do
      expect(rendered).to have_css('table.table-striped th.col-md-3', text: 'Date', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-md-2', text: 'Requested By', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-md-1', text: 'Items Indexed', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-md-2', text: 'Elapsed Time', count: 1)
      expect(rendered).to have_css('table.table-striped th.col-md-2', text: 'Status', count: 1)
    end

    it 'formats the start time correctly' do
      expect(rendered).to have_css('table.table-striped td', text: '05 Jan 23:00', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: '10 Jan 23:00', count: 1)
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

    it 'displays nothing in the duration column or start time column when the info is unavailable (e.g. unstarted or in_progress attempts)' do
      # we expect 2 blank durations, and 1 blank start time (1 unstarted log entry w/ blank start and duration, 1 in_progress w/ blank duration)
      expect(rendered).to have_css('table.table-striped td', text: /^$/, count: 3)
    end

    it 'displays the status of the reindexing attempt using localized text' do
      expect(rendered).to have_css('table.table-striped td', text: 'Not Yet Started', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Successful', count: 2)
      expect(rendered).to have_css('table.table-striped td', text: 'In Progress', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Failed', count: 1)
    end
  end

  context 'a reindexing log entry has a null user' do
    it 'displays blank in the user field and renders without error' do
      assign(:recent_reindexing, [FactoryBot.build(:reindexing_log_entry_no_user)])
      expect { render p }.not_to raise_error

      # we expect one blank table cell for the user, and values for everything else
      expect(rendered).to have_css('table.table-striped td', text: /^$/, count: 1)
      expect(rendered).to have_css('table.table-striped td', text: '05 Jan 23:00', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: /^10$/, count: 1)
      expect(rendered).to have_css('table.table-striped td', text: '5 minutes', count: 1)
      expect(rendered).to have_css('table.table-striped td', text: 'Successful', count: 1)
    end
  end
end
