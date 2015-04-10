require 'spec_helper'

describe 'spotlight/feature_pages/_sidebar.html.erb', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:parent1) { FactoryGirl.create(:feature_page, exhibit: exhibit, title: 'Parent Page') }
  let!(:parent2) { FactoryGirl.create(:feature_page, exhibit: exhibit, title: 'Two') }
  let!(:child1) { FactoryGirl.create(:feature_page, exhibit: exhibit, parent_page: parent1, title: 'Three', weight: 4) }
  let!(:child2) { FactoryGirl.create(:feature_page, exhibit: exhibit, parent_page: parent2, title: 'Four') }
  let!(:child3) { FactoryGirl.create(:feature_page, exhibit: exhibit, parent_page: parent1, title: 'Five', weight: 2) }
  let!(:child4) { FactoryGirl.create(:feature_page, exhibit: exhibit, parent_page: parent1, title: 'Six', published: false) }
  let!(:child5) { FactoryGirl.create(:feature_page, exhibit: FactoryGirl.create(:exhibit), title: 'Seven') }

  before do
    allow(view).to receive_messages(current_exhibit: parent1.exhibit)
    allow(view).to receive_messages(feature_page_path: '/feature/9')
    assign(:exhibit, parent1.exhibit)
  end

  it 'renders a list of pages for a parent page' do
    assign(:page, parent1)
    allow(view).to receive(:current_page?).and_return(true, false)
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector 'li.active h4', text: 'Parent Page'
    expect(rendered).to have_selector '#sidebar ol.sidenav li:nth-child(1) a', text: 'Five'
    expect(rendered).to have_selector '#sidebar ol.sidenav li:nth-child(2) a', text: 'Three'
    expect(rendered).to have_selector 'li h4 a', text: 'Two' # a different parent page
    expect(rendered).to have_link 'Four' # different parent
    expect(rendered).not_to have_link 'Six' # not published
    expect(rendered).not_to have_link 'Seven' # different exhibit
  end

  it 'renders a list of pages from a child page' do
    assign(:page, child1)
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector 'h4', text: 'Parent Page'
    expect(rendered).to have_selector '#sidebar ol.sidenav li:nth-child(1) a', text: 'Five'
    expect(rendered).to have_selector '#sidebar ol.sidenav li:nth-child(2) a', text: 'Three'
    expect(rendered).to have_content 'Two' # not selected page
    expect(rendered).to have_link 'Four' # different parent
    expect(rendered).not_to have_link 'Six' # not published
  end
end
