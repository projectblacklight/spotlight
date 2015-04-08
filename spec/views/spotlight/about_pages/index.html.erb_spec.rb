require 'spec_helper'

describe 'spotlight/about_pages/index.html.erb', type: :view do
  let(:pages) do
    [
      stub_model(Spotlight::AboutPage,
                 title: 'Title1',
                 content: '[]',
                 exhibit: exhibit
                ),
      stub_model(Spotlight::AboutPage,
                 title: 'Title2',
                 content: '[]',
                 exhibit: exhibit
                )
    ]
  end
  let(:contacts) do
    [
      stub_model(Spotlight::Contact,
                 exhibit: exhibit
                ),
      stub_model(Spotlight::Contact,
                 exhibit: exhibit
                )
    ]
  end
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    allow(view).to receive(:disable_save_pages_button?).and_return(false)
    allow(view).to receive(:page_collection_name).and_return(:about_pages)
    allow(view).to receive(:update_all_exhibit_about_pages_path).and_return('/exhibit/about/update_all')
    allow(view).to receive(:exhibit_contacts_path).and_return('/exhibit/1/contacts')
    allow(view).to receive(:nestable_data_attributes).and_return('data-behavior="nestable"')
    allow(exhibit).to receive_messages(contacts: contacts)
    assign(:page, Spotlight::AboutPage.new)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    view.lookup_context.prefixes << 'spotlight/pages'
    allow(view).to receive(:can?).and_return(true)
  end

  it 'renders a list of pages and contacts' do
    assign(:pages, pages)
    allow(exhibit).to receive(:about_pages).and_return pages
    render
    expect(rendered).to have_selector '.panel-title', text: 'Title1'
    expect(rendered).to have_selector '.panel-title', text: 'Title2'

    expect(rendered).to have_selector '.contacts_admin ol.dd-list li[data-id]', count: 2
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input[data-property=weight]', count: 2
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input#exhibit_contacts_attributes_0_id'
    expect(rendered).to have_selector '.contacts_admin ol.dd-list li input#exhibit_contacts_attributes_1_id'
  end

  describe 'Save button' do
    it 'is disabled the when the pages are blank' do
      allow(view).to receive(:disable_save_pages_button?).and_return(true)
      assign(:pages, [])
      render
      expect(rendered).to have_selector 'button[disabled]', text: 'Save changes'
    end
    it 'does not be disabled the when there are pages' do
      allow(view).to receive(:disable_save_pages_button?).and_return(false)
      assign(:pages, [{}])
      render
      expect(rendered).not_to have_selector 'button[disabled]', text: 'Save changes'
      expect(rendered).to have_selector 'button', text: 'Save changes'
    end
  end
end
