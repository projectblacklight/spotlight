describe 'spotlight/browse/search', type: :view do
  let(:search) { FactoryBot.create(:search) }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  before do
    allow(search).to receive_messages(documents: double(size: 15))
    allow(search).to receive_message_chain(:thumbnail, iiif_url: '/some/image')
  end

  before do
    assign :exhibit, exhibit
  end

  it 'displays the image' do
    render partial: 'spotlight/browse/search', locals: { search: search }
    expect(response).to have_selector 'a img[src="/some/image"]'
  end

  it 'has a heading' do
    render partial: 'spotlight/browse/search', locals: { search: search }
    expect(response).to have_link search.title, href: spotlight.exhibit_browse_path(exhibit, search)
  end

  it 'displays the item count' do
    render partial: 'spotlight/browse/search', locals: { search: search }
    expect(response).to have_selector 'small', text: /#{search.documents.size} items/i
  end
end
