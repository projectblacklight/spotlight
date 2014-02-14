require 'spec_helper'

describe "spotlight/searches/_search.html.erb" do
  
  let(:search) { stub_model(Spotlight::Search,
        id: 99, title: "Title1", short_description: "MyText") }
  before do
    view.send(:extend, Spotlight::CrudLinkHelpers)
    view.stub(:edit_search_path).and_return("/edit")
    view.stub(:search_path).and_return("/search")

    form_for(search, url: '/update') do |f|
      @f = f
    end
  end

  it "renders a list of pages" do
    render :partial => "spotlight/searches/search", :locals => { f: @f}
    expect(rendered).to have_selector "li[data-id='99']"
    expect(rendered).to have_selector '.panel-heading .main .title', text: 'Title1'
    expect(rendered).to have_selector 'input[type=hidden][data-property=weight]'
  end
end

