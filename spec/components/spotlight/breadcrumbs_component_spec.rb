# frozen_string_literal: true

RSpec.describe Spotlight::BreadcrumbsComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(breadcrumbs: [Breadcrumb.new('breadcrumb 1', '/path1'), Breadcrumb.new('breadcrumb 2', '/path2')]) }

  it 'has the first breadcrumb as text' do
    expect(rendered).to have_link 'breadcrumb 1'
  end

  it 'has the last breadcrumb as text' do
    expect(rendered).to have_content 'breadcrumb 2'
  end

  it 'has 2 breadcrumbs' do
    expect(rendered.all('.breadcrumb-item').count).to be 2
  end
end
