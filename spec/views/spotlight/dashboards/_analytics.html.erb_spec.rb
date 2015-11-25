require 'spec_helper'

describe 'spotlight/dashboards/_analytics.html.erb', type: :view do
  let(:current_exhibit) { FactoryGirl.create(:exhibit) }
  let(:ga_data) { OpenStruct.new(pageviews: 1, users: 2, sessions: 3) }
  let(:page_data) { [OpenStruct.new(pageTitle: 'title', pagePath: '/path', pageviews: '123')] }
  before do
    allow(view).to receive_messages(current_exhibit: current_exhibit, exhibit_root_path: '/some/path')
    allow(current_exhibit).to receive(:analytics).and_return(ga_data)
    allow(current_exhibit).to receive(:page_analytics).and_return(page_data)
  end

  it 'uses the exhibit_root_path for analytics' do
    expect(current_exhibit).to receive(:analytics).with(1.month, '/some/path').and_return(ga_data)
    expect(current_exhibit).to receive(:page_analytics).with(1.month, '/some/path').and_return(page_data)
    render
  end

  it 'has header' do
    render
    expect(rendered).to have_content 'User Activity Over the Past Month'
  end

  it 'has metric labels' do
    render
    expect(rendered).to have_content 'visitors'
    expect(rendered).to have_content 'unique visits'
    expect(rendered).to have_content 'page views'
  end

  it 'has metric values' do
    render
    expect(rendered).to have_selector '.value.pageviews', text: 1
    expect(rendered).to have_selector '.value.users', text: 2
    expect(rendered).to have_selector '.value.sessions', text: 3
  end

  it 'has page-level data' do
    render
    expect(rendered).to have_content 'Most popular pages'
    expect(rendered).to have_link 'title', href: '/path'
    expect(rendered).to have_content '123'
  end
end
