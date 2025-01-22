# frozen_string_literal: true

RSpec.describe 'spotlight/browse/index', type: :view do
  let(:search) { FactoryBot.create(:search) }
  let(:another_search) { FactoryBot.create(:search) }

  before { allow(view).to receive(:current_exhibit).and_return(search.exhibit) }

  it 'has a title' do
    assign :groups, []
    render
    expect(response).to have_selector 'h1', text: 'Browse'
  end

  it 'renders the collection of searches' do
    assign :groups, []
    assign :searches, [search, another_search]
    stub_template 'spotlight/browse/_search.html.erb' => '<%= search.id %> <br/>'
    render
    expect(response).to have_content "#{search.id} #{another_search.id}"
  end
end
