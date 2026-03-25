# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_uploaded_items_block', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/uploaded_items_block' }
  let(:page) { double('Page') }
  let(:block) do
    SirTrevorRails::Blocks::UploadedItemsBlock.new(
      { type: 'block', data: { title: 'Some title', text: 'Some text', 'text-align' => 'right', zpr_link: 'true' } }, page
    )
  end

  before do
    allow(block).to receive(:files)
      .and_return([
                    { id: 1, url: 'http://example.com', link: 'http://example.com/link1', caption: 'Caption 1', alt_text: 'custom alt text' },
                    { id: 2, url: 'http://example.com', link: nil, caption: nil, decorative: 'on' },
                    { id: 3, url: 'http://example.com', link: 'http://example.com/link3', caption: 'Caption 3' }
                  ])
    render partial:, locals: { uploaded_items_block: block }
  end

  it 'has an uploaded items block' do
    expect(rendered).to have_css 'h3', text: 'Some title'
    expect(rendered).to have_content 'Some text'
    expect(rendered).to have_css '.caption', text: 'Caption 1'
    expect(rendered).to have_css '.caption', text: 'Caption 3'
    expect(rendered).to have_css 'a[href="http://example.com/link1"]'
    expect(rendered).to have_css 'a[href="http://example.com/link3"]'
    expect(rendered).to have_css 'img[src="http://example.com"]', count: 3
    expect(rendered).to have_css 'button.zpr-link', count: 3
  end

  it 'uses the correct alt text' do
    expect(rendered).to have_css 'img[alt="custom alt text"]'
    expect(rendered).to have_css 'img[alt=""]'
    expect(rendered).to have_css 'img[alt="Caption 3"]'
  end
end
