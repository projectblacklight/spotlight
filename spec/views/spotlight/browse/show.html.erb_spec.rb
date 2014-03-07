require 'spec_helper'

describe 'spotlight/browse/show' do
  let(:search) { FactoryGirl.create(:published_search) }
  let(:exhibit) { Spotlight::ExhibitFactory.default }

  before :each do
    search.stub(count: 15)
    view.stub(render_document_index_with_view: "")
    stub_template("_results_pagination.html.erb" => "")
  end

  before :each do
    assign :exhibit, exhibit
    assign :search, search
    assign :document_list, []
  end

  it "should display the image" do
    search.stub(featured_image: "xyz")
    render
    expect(response).to have_selector '.media img'
  end

  it "should have a heading" do
    render
    expect(response).to have_selector 'h1', text: search.title
  end

  it "should display the item count" do
    render
    expect(response).to have_selector ".item-count", text: "#{search.count} items"
  end

  it "should display the long description" do
    search.stub(long_description: "Long description")
    render
    expect(response).to have_selector "p", text: search.long_description
  end

  it "should display the search results" do
    view.should_receive(:render_document_index_with_view).with(:gallery, []).and_return "Gallery View"
    render
    expect(response).to match /Gallery View/
  end
end