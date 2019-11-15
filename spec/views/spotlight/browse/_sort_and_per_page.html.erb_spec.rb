# frozen_string_literal: true

describe 'spotlight/browse/_sort_and_per_page', type: :view do
  before do
    allow(view).to receive_messages(render_results_collection_tools: 'collection tools')
  end

  it 'renders the pagination, sort, per page and view type controls' do
    render
    expect(rendered).to have_content 'collection tools'
  end
end
