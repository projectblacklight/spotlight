# frozen_string_literal: true

describe 'spotlight/pages/show', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:page) do
    stub_model(Spotlight::FeaturePage,
               exhibit: exhibit,
               title: 'Title',
               content: '[]')
  end

  before do
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    assign(:page, page)
    stub_template 'spotlight/pages/_sidebar.html.erb' => 'Sidebar'
    stub_template 'spotlight/pages/_tophat.html.erb' => ''
  end

  it 'renders the title as a heading' do
    render
    expect(rendered).to have_css('.page-title', text: page.title)
  end

  it 'does not render an empty heading' do
    allow(page).to receive_messages(title: nil)
    render
    expect(rendered).not_to have_css('.page-title')
  end

  it 'injects the page title into the html title' do
    expect(view).to receive(:set_html_page_title)
    render
  end

  it 'does not double-escape HTML entities in the HTML title' do
    allow(page).to receive_messages(title: 'Abbott & Costello')
    stub_template 'shared/_user_util_links.html.erb' => ''
    stub_template 'shared/_masthead.html.erb' => ''
    render template: 'spotlight/pages/show', layout: 'layouts/spotlight/spotlight'
    expect(rendered).to have_content('Abbott & Costello | Blacklight')
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
