require 'spec_helper'

describe 'spotlight/browse/show', type: :view do
  let(:search) { FactoryGirl.create(:published_search) }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  before :each do
    allow(view).to receive_messages(resource_masthead?: false)
    allow(view).to receive_messages(blacklight_config: Blacklight::Configuration.new)
    view.blacklight_config.view.gallery = true
    allow(search).to receive_messages(documents: double(size: 15))
    allow(view).to receive_messages(render_document_index_with_view: '')
    stub_template('_results_pagination.html.erb' => '')
    stub_template('_sort_and_per_page.html.erb' => 'Sort and Per Page actions')
  end

  before :each do
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
    expect(response).to have_selector 'p', text: search.long_description
  end

  it 'displays search results actions' do
    render
    expect(response).to have_content 'Sort and Per Page actions'
  end

  it 'displays the search results' do
    expect(view).to receive(:render_document_index_with_view).with(:gallery, anything, anything).and_return 'Gallery View'
    render
    expect(response).to include 'Gallery View'
  end
end
