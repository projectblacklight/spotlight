require 'spec_helper'

describe "spotlight/about_pages/index.html.erb" do
  let(:pages) {[
      stub_model(Spotlight::AboutPage,
        :title => "Title1",
        :content => "MyText",
        exhibit: exhibit
      ),
      stub_model(Spotlight::AboutPage,
        :title => "Title2",
        :content => "MyText",
        exhibit: exhibit
      )
    ]}
  let(:contacts) {[
      stub_model(Spotlight::Contact,
        exhibit: exhibit
      ),
      stub_model(Spotlight::Contact,
        exhibit: exhibit
      )
    ]}
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    view.stub(:disable_save_pages_button?).and_return(false)
    view.stub(:page_collection_name).and_return(:about_pages)
    view.stub(:update_all_exhibit_about_pages_path).and_return("/exhibit/about/update_all")
    view.stub(:exhibit_contacts_path).and_return("/exhibit/1/contacts")
    exhibit.stub(:contacts => contacts)
    assign(:page, Spotlight::AboutPage.new)
    assign(:exhibit, exhibit)
    view.stub(:current_exhibit).and_return(exhibit)
    view.lookup_context.prefixes << 'spotlight/pages'
  end

  it "renders a list of pages and contacts" do
    assign(:pages, pages)
    exhibit.stub(:about_pages).and_return pages
    render
    expect(rendered).to have_selector '.panel-title', text: 'Title1'
    expect(rendered).to have_selector '.panel-title', text: 'Title2'

    expect(rendered).to have_selector '.contacts_admin ol.dd-list li[data-id]', count: 2
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input[data-property=weight]', count: 2
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input#exhibit_contacts_attributes_0_id'
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input#exhibit_contacts_attributes_1_id'
  end

  describe "Save button" do
    it "should be disabled the when the pages are blank" do
      view.stub(:disable_save_pages_button?).and_return(true)
      assign(:pages, [])
      render
      expect(rendered).to have_selector 'button[disabled]', text: "Save changes"
    end
    it "should not be disabled the when there are pages" do
      view.stub(:disable_save_pages_button?).and_return(false)
      assign(:pages, [{}])
      render
      expect(rendered).not_to have_selector 'button[disabled]', text: "Save changes"
      expect(rendered).to     have_selector 'button',           text: "Save changes"
    end
  end

end
