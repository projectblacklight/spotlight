describe 'spotlight/browse/show', type: :view do
  let(:search) { FactoryBot.create(:published_search) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(view).to receive_messages(resource_masthead?: false)
    allow(view).to receive_messages(blacklight_config: Blacklight::Configuration.new)
    allow(search).to receive_messages(documents: double(size: 15))
    allow(view).to receive_messages(render_document_index_with_view: '')
    stub_template('_results_pagination.html.erb' => '')
    stub_template('_sort_and_per_page.html.erb' => 'Sort and Per Page actions')
    stub_template 'spotlight/browse/_tophat.html.erb' => ''
  end

  before do
    assign :exhibit, exhibit
    assign :search, search
    assign :document_list, []
  end

  it 'has a heading and item count when there is no current search masthead' do
    render
    expect(response).to have_selector 'h1', text: search.title
    expect(response).to have_selector '.item-count', text: "#{search.documents.size} items"
  end

  it 'does not have the heading and item count when there is a current search masthead' do
    allow(view).to receive_messages(resource_masthead?: true)
    render
    expect(response).to_not have_selector 'h1', text: search.title
    expect(response).to_not have_selector '.item-count', text: "#{search.documents.size} items"
  end

  it 'has an edit button' do
    allow(view).to receive_messages(can?: true)
    render
    expect(response).to have_selector '.btn', text: 'Edit'
  end

  it 'displays the long description' do
    allow(search).to receive_messages(long_description: 'Long description')
    render
    expect(response).to have_selector '.long-description-text p', text: search.long_description
    expect(response).not_to have_selector '.very-long-description-text'
  end

  it 'adds markup for very long descriptions' do
    allow(search).to receive_messages(long_description: 'A' * 601)
    render
    expect(response).to have_selector '.very-long-description-text p'
  end

  it 'renders the long description as markdown' do
    allow(search).to receive_messages(long_description: '[some link](/somewhere)')
    render
    expect(response).to have_selector 'p a', text: 'some link'
  end

  it 'displays search results actions' do
    render
    expect(response).to have_content 'Sort and Per Page actions'
  end
end
