# frozen_string_literal: true

describe 'spotlight/dashboards/analytics.html.erb', type: :view do
  let(:current_exhibit) { FactoryBot.create(:exhibit) }
  let(:enabled) { true }
  let(:data) do
    OpenStruct.new(rows: [OpenStruct.new(pageTitle: 'title', pagePath: '/path', screenPageViews: '123')],
                   totals: OpenStruct.new(screenPageViews: 1, users: 2, sessions: 3))
  end

  before do
    allow(current_exhibit).to receive(:page_analytics).and_return(data)
    allow(current_exhibit).to receive(:analytics).and_return(data)
    allow(current_exhibit).to receive(:analytics_provider).and_return(double(Spotlight::Analytics::Ga, enabled?: enabled))
    allow(view).to receive_messages(current_exhibit: current_exhibit, exhibit_root_path: '/some/path')
  end

  context 'without a configured analytics integration' do
    let(:enabled) { false }

    it 'has a header' do
      render
      expect(rendered).to have_selector '.page-header', text: 'Curation'
      expect(rendered).to have_selector '.page-header small', text: 'Analytics'
    end

    it 'has directions for configuring analytics' do
      render
      expect(rendered).to have_text 'configure an analytics provider'
    end
  end

  context 'with a configured analytics integration' do
    it 'has analytics data' do
      render

      expect(rendered).to have_content 'User activity over the past year'
    end
  end
end
