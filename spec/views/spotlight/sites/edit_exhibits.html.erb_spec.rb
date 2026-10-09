# frozen_string_literal: true

RSpec.describe 'spotlight/sites/edit_exhibits', type: :view do
  let!(:exhibit_a) { FactoryBot.create(:exhibit) }
  let!(:exhibit_b) { FactoryBot.create(:exhibit, published: true, discovery_enabled: false) }
  let!(:exhibit_c) { FactoryBot.create(:exhibit, published: false) }

  before do
    assign(:site, Spotlight::Site.instance)
    allow(view).to receive_messages(exhibit_path: nil)
  end

  it 'has columns for the exhibit data' do
    render
    expect(rendered).to have_css 'th', text: 'Title'
    expect(rendered).to have_css 'th', text: 'Published?'
    expect(rendered).to have_css 'th', text: 'Requested by'
    expect(rendered).to have_css 'th', text: 'Created at'
    expect(rendered).to have_css 'th', text: 'Updated at'
  end

  it 'has draggable rows for each exhibit' do
    render
    expect(rendered).to have_css 'tr .dd-handle', count: 3
  end

  it 'shows the publishing status of each exhibit' do
    render
    expect(rendered).to have_css "tr[data-id='#{exhibit_a.id}'] td", exact_text: 'Published'
    expect(rendered).to have_css "tr[data-id='#{exhibit_b.id}'] td", exact_text: 'Preview'
    expect(rendered).to have_css "tr[data-id='#{exhibit_c.id}'] td", exact_text: 'Unpublished'
  end
end
