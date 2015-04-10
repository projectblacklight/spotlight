require 'spec_helper'

describe 'spotlight/pages/index.html.erb', type: :view do
  let(:pages) do
    [
      stub_model(Spotlight::FeaturePage,
                 title: 'Title1',
                 content: '[]',
                 exhibit: exhibit
                ),
      stub_model(Spotlight::FeaturePage,
                 title: 'Title2',
                 content: '[]',
                 exhibit: exhibit
                )
    ]
  end
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    allow(view).to receive(:page_collection_name).and_return(:feature_pages)
    allow(view).to receive(:update_all_exhibit_feature_pages_path).and_return('/exhibit/features/update_all')
    assign(:page, Spotlight::FeaturePage.new)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  it 'renders a list of pages' do
    assign(:pages, pages)
    allow(exhibit).to receive(:feature_pages).and_return pages
    render
    expect(rendered).to have_selector '.panel-title', text: 'Title1'
    expect(rendered).to have_selector '.panel-title', text: 'Title2'
  end

  describe 'Without pages' do
    it 'does not disable the update button' do
      assign(:pages, [])
      render
      expect(rendered).not_to have_selector 'button[disabled]', text: 'Save changes'
      expect(rendered).to have_selector 'button', text: 'Save changes'
    end
  end
end
