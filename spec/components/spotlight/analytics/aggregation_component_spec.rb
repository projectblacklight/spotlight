# frozen_string_literal: true

RSpec.describe Spotlight::Analytics::AggregationComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(data: data, exclude_fields: exclude_fields)).to_s)
  end

  let(:data) do
    OpenStruct.new(screenPageViews: 1, users: 2, sessions: 3)
  end

  let(:exclude_fields) { [] }

  it 'has a table with all three fields displayed' do
    expect(rendered).to have_css('th', text: 'page views')
    expect(rendered).to have_css('th', text: 'unique visits')
    expect(rendered).to have_css('th', text: 'sessions')

    expect(rendered).to have_css('td', class: 'value screenPageViews', text: '1')
    expect(rendered).to have_css('td', class: 'value users', text: '2')
    expect(rendered).to have_css('td', class: 'value sessions', text: '3')
  end

  context 'when there is no data' do
    let(:data) { OpenStruct.new }

    it 'is blank' do
      expect(rendered.native.inner_html).to eq('')
    end
  end

  context 'when exclude_fields is set' do
    let(:exclude_fields) { [:screenPageViews] }

    it 'has a table with two fields displayed' do
      expect(rendered).to have_no_css('th', text: 'page views')
      expect(rendered).to have_css('th', text: 'unique visits')
      expect(rendered).to have_css('th', text: 'sessions')

      expect(rendered).to have_no_css('td', class: 'value screenPageViews', text: '1')
      expect(rendered).to have_css('td', class: 'value users', text: '2')
      expect(rendered).to have_css('td', class: 'value sessions', text: '3')
    end
  end
end
