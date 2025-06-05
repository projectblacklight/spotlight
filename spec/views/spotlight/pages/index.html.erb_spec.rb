# frozen_string_literal: true

RSpec.describe 'spotlight/pages/index.html.erb', type: :view do
  let(:pages) do
    [
      stub_model(Spotlight::FeaturePage,
                 title: 'Title1',
                 content: '[]',
                 exhibit:),
      stub_model(Spotlight::FeaturePage,
                 title: 'Title2',
                 content: '[]',
                 exhibit:)
    ]
  end
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:default_language) { true }

  before do
    allow(view).to receive(:page_collection_name).and_return(:feature_pages)
    allow(view).to receive(:exhibit_alt_text_path).and_return('/')
    allow(view).to receive(:update_all_exhibit_feature_pages_path).and_return('/exhibit/features/update_all')
    allow(view).to receive(:default_language?).and_return(default_language)
    assign(:page, Spotlight::FeaturePage.new)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  it 'renders a list of pages' do
    assign(:pages, pages)
    allow(exhibit).to receive(:feature_pages).and_return pages
    render
    expect(rendered).to have_selector '.card-title', text: 'Title1'
    expect(rendered).to have_selector '.card-title', text: 'Title2'
  end

  describe 'Without pages' do
    it 'does not disable the update button' do
      assign(:pages, [])
      render
      expect(rendered).to have_no_selector 'button[disabled]', text: 'Save changes'
      expect(rendered).to have_selector 'button', text: 'Save changes'
    end
  end

  describe 'when a locale other than the default is set' do
    let(:default_language) { false }

    before do
      assign(:pages, pages)
      allow(exhibit).to receive(:feature_pages).and_return pages
      render
    end

    it 'removes the form and displays a translations message' do
      expect(rendered).to have_text 'Please use the translations editor'
      expect(rendered).to have_no_selector '.card-title', text: 'Title1'
      expect(rendered).to have_no_selector '.card-title', text: 'Title2'
    end
  end
end
