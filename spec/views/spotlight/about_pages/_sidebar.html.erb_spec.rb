describe 'spotlight/about_pages/_sidebar.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:page1) { FactoryBot.create(:about_page, title: 'One', weight: 4, exhibit: exhibit) }
  let!(:page2) { FactoryBot.create(:about_page, exhibit: exhibit, title: 'Two', published: false) }
  let!(:page3) { FactoryBot.create(:about_page, exhibit: exhibit, title: 'Three', weight: 3) }

  before do
    allow(view).to receive_messages(current_exhibit: exhibit)
    allow(view).to receive_messages(exhibit_about_page_path: '/about/9')
    assign(:exhibit, page1.exhibit)
  end

  it 'renders a list of pages' do
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector '#sidebar ul.sidenav li:nth-child(1) a', text: 'Three'
    expect(rendered).to have_selector '#sidebar ul.sidenav li:nth-child(2) a', text: 'One'
    expect(rendered).to have_link 'Three', href: "/spotlight/#{exhibit.slug}/about/three"
    expect(rendered).to have_link 'One', href: "/spotlight/#{exhibit.slug}/about/one"
    expect(rendered).not_to have_link 'Two'
  end
end
