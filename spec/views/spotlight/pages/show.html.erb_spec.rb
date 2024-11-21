# frozen_string_literal: true

describe 'spotlight/pages/show', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:page) do
    stub_model(Spotlight::FeaturePage,
               exhibit:,
               title: 'Title',
               content: '[]')
  end

  before do
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    allow(view).to receive(:blacklight_config).and_return(Blacklight.default_configuration)
    allow(view).to receive(:render_body_class).and_return('')
    allow(view).to receive(:add_page_meta_content).and_return('')
    allow(view).to receive(:description).and_return('')
    assign(:page, page)
    stub_template 'spotlight/pages/_sidebar.html.erb' => 'Sidebar'
  end

  it 'renders the title as a heading' do
    render
    expect(rendered).to have_css('.page-title', text: page.title)
  end

  it 'does not render an empty heading' do
    allow(page).to receive_messages(title: nil)
    render
    expect(rendered).to have_no_css('.page-title')
  end

  it 'injects the page title into the html title' do
    expect(view).to receive(:set_html_page_title)
    render
  end

  context 'when rendering with layout' do
    let(:blacklight_config) { Blacklight::Configuration.new header_component: Spotlight::HeaderComponent }
    let(:document) { SolrDocument.new id: 'xyz', format: 'a' }
    let(:presenter) { Blacklight::ShowPresenter.new(document, view, blacklight_config) }

    before do
      allow(page).to receive_messages(title: 'Abbott & Costello')
      allow_any_instance_of(Spotlight::Exhibit).to receive(:searchable?).and_return(true)
      stub_template 'shared/_analytics.html.erb' => 'analytics'
      stub_template 'shared/_user_util_links.html.erb' => ''
      stub_template 'shared/_masthead.html.erb' => ''
      allow(view).to receive_messages(document_presenter: presenter, action_name: 'show', blacklight_config:)
      allow(view).to receive(:content?).and_return(true)
      allow(view).to receive(:search_action_url).and_return('/catalog')
      allow(view).to receive(:add_exhibit_meta_content).and_return('')
      render template: 'spotlight/pages/show', layout: 'layouts/spotlight/spotlight'
    end

    it 'does not double-escape HTML entities in the HTML title' do
      expect(rendered).to have_content('Abbott & Costello | Blacklight')
    end

    it 'includes analytics reporting' do
      expect(rendered).to have_content 'analytics'
    end
  end

  it 'does not include the page title' do
    allow(page).to receive_messages(should_display_title?: false)
    expect(view).not_to receive(:set_html_page_title)
    render
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Title/)
  end

  it 'renders the sidebar' do
    page.display_sidebar = true
    render
    expect(view.content_for(:sidebar)).to match('Sidebar')
  end

  it 'does not render the sidebar if the page has it disabled' do
    allow(page).to receive_messages(display_sidebar?: false)
    render
    expect(view.content_for(:sidebar)).not_to match('Sidebar')
  end

  it 'renders an empty partial if the page has no content' do
    allow(page).to receive_messages(content?: false)
    stub_template 'spotlight/pages/_empty.html.erb' => 'Empty message'
    render
    expect(rendered).to have_content('Empty message')
  end
end
