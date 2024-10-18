# frozen_string_literal: true

RSpec.describe Spotlight::Analytics::DashboardComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(current_exhibit:) }

  let(:current_exhibit) { instance_double(Spotlight::Exhibit, page_analytics: data, analytics: data) }
  let(:data) do
    OpenStruct.new(rows: [OpenStruct.new(pageTitle: 'title', pagePath: '/path', screenPageViews: '123')],
                   totals: OpenStruct.new(screenPageViews: 1, users: 2, sessions: 3))
  end

  before do
    allow_any_instance_of(SpotlightHelper).to receive(:exhibit_root_path).and_return('/path')
  end

  it 'shows translated header' do
    expect(rendered).to have_content 'User activity over the past year'
  end

  it 'has metric labels' do
    expect(rendered).to have_content 'page views'
    expect(rendered).to have_content 'unique visits'
    expect(rendered).to have_content 'sessions'
  end

  it 'has metric values' do
    expect(rendered).to have_selector '.value.screenPageViews', text: 1
    expect(rendered).to have_selector '.value.users', text: 2
    expect(rendered).to have_selector '.value.sessions', text: 3
  end

  it 'has page-level data' do
    expect(rendered).to have_content 'Most popular pages'
    expect(rendered).to have_link 'title', href: '/path'
    expect(rendered).to have_content '123'
  end

  context 'does not have any anayltics data' do
    let(:data) { OpenStruct.new(rows: [], totals: OpenStruct.new) }

    it 'has a no analytics message' do
      expect(rendered).to have_content I18n.t('spotlight.dashboards.analytics.no_results', pageurl: '/path')
    end
  end
end
