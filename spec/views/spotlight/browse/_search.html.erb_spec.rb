require 'spec_helper'

describe 'spotlight/browse/search', type: :view do
  let(:search) { FactoryGirl.create(:search) }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  before :each do
    allow(search).to receive_messages(documents: double(size: 15))
    allow(search).to receive_message_chain(:thumbnail, :image, thumb: '/some/image')
  end

  before :each do
    assign :exhibit, exhibit
  end

  it 'displays the image' do
    render partial: 'spotlight/browse/search', locals: { search: search }
    expect(response).to have_selector 'a img'
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
