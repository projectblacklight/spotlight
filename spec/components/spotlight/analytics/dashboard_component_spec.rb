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

  let(:default_start_date) { 1.year.ago.to_date.to_s }
  let(:default_end_date) { Time.zone.today.to_date.to_s }
  let(:default_min_date) { '2015-08-14' } # This is the minimum date GA's API will allow

  before do
    allow_any_instance_of(SpotlightHelper).to receive(:exhibit_root_path).and_return('/path')
    allow_any_instance_of(Rails.application.routes.url_helpers).to receive(:analytics_exhibit_dashboard_path).and_return('/path')
  end

  def get_min_max(field)
    field = rendered.find("input[name='#{field}']")
    { min: field[:min], max: field[:max] }
  end

  context 'default page load' do
    it 'has start and end date selectors' do
      expect(get_min_max('start_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(get_min_max('end_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(rendered).to have_field('start_date', with: default_start_date)
      expect(rendered).to have_field('end_date', with: default_end_date)
      expect(rendered).to have_content 'User activity over the past year'
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
  end

  context 'has valid start and end date params' do
    it 'updates the header and selector to param values' do
      start_date = '2024-01-01'
      end_date = '2024-01-02'
      vc_test_controller.params[:start_date] = start_date
      vc_test_controller.params[:end_date] = end_date
      expect(get_min_max('start_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(get_min_max('end_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(rendered).to have_field('start_date', with: start_date)
      expect(rendered).to have_field('end_date', with: end_date)
      expect(rendered).to have_content "User activity from #{component.formatted_date(start_date)} to #{component.formatted_date(end_date)}"
    end
  end

  context 'has invalid start and end date params' do
    it 'updates the header and selector to default values' do
      vc_test_controller.params[:start_date] = '2024-41-01'
      vc_test_controller.params[:end_date] = '2024-31-02'
      expect(get_min_max('start_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(get_min_max('end_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(rendered).to have_field('start_date', with: default_start_date)
      expect(rendered).to have_field('end_date', with: default_end_date)
      expect(rendered).to have_content "User activity from #{component.formatted_date(default_start_date)} to #{component.formatted_date(default_end_date)}"
    end
  end

  context 'has a start date larger than end date' do
    it 'updates the header and selector to default values' do
      vc_test_controller.params[:start_date] = '2024-02-02'
      vc_test_controller.params[:end_date] = '2024-02-01'
      expect(get_min_max('start_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(get_min_max('end_date')).to eq({ max: default_end_date, min: default_min_date })
      expect(rendered).to have_field('start_date', with: default_start_date)
      expect(rendered).to have_field('end_date', with: default_end_date)
      expect(rendered).to have_content "User activity from #{component.formatted_date(default_start_date)} to #{component.formatted_date(default_end_date)}"
    end
  end

  context 'Spotlight::Engine.config.ga_date_range is set' do
    let(:start_date) { 6.months.ago.to_date.to_s }
    let(:end_date) { 3.months.ago.to_date.to_s }

    before do
      Spotlight::Engine.config.ga_date_range = { 'start_date' => 6.months.ago, 'end_date' => 3.months.ago }
    end

    after do
      Spotlight::Engine.config.ga_date_range = { 'start_date' => nil, 'end_date' => nil }
    end

    it 'has start and end date selectors' do
      expect(get_min_max('start_date')).to eq({ max: end_date, min: start_date })
      expect(get_min_max('end_date')).to eq({ max: end_date, min: start_date })
      expect(rendered).to have_field('start_date', with: start_date)
      expect(rendered).to have_field('end_date', with: end_date)
      expect(rendered).to have_content 'User activity over the past year'
    end

    it 'has invalid start and end date params' do
      vc_test_controller.params[:start_date] = '2024-41-01'
      vc_test_controller.params[:end_date] = '2024-31-02'
      expect(get_min_max('start_date')).to eq({ max: end_date, min: start_date })
      expect(get_min_max('end_date')).to eq({ max: end_date, min: start_date })
      expect(rendered).to have_field('start_date', with: start_date)
      expect(rendered).to have_field('end_date', with: end_date)
      expect(rendered).to have_content "User activity from #{component.formatted_date(start_date)} to #{component.formatted_date(end_date)}"
    end
  end

  context 'does not have any anayltics data' do
    let(:data) { OpenStruct.new(rows: [], totals: OpenStruct.new) }

    it 'has a no analytics message' do
      expect(rendered).to have_content I18n.t('spotlight.dashboards.analytics.no_results', pageurl: '/path')
    end
  end
end
