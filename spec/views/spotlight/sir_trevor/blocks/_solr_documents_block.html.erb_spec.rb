require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_solr_documents_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_block.html.erb' }
  let(:page) { double('Page') }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsBlock.new({ type: 'block', data: { title: 'Some title', text: 'Some text', 'text-align' => 'right' } }, page)
  end
  let(:doc) { blacklight_config.document_model.new(id: 1) }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.view.embed.partials = %w(a b c)
      config.view.embed.locals = { a: 1 }
    end
  end

  before do
    allow(block).to receive(:each_document).and_yield({}, doc)
    allow(block).to receive(:documents?).and_return(true)
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb', document_link_params: {})
  end

  context 'with a multi-image object' do
    let(:block_options) { { thumbnail_image_url: 'http://example.com' } }
    before do
      allow(block).to receive(:each_document).and_yield(block_options, doc)
    end

    it 'uses the provided thumbnail url' do
      render partial: p, locals: { solr_documents_block: block }
      expect(rendered).to have_selector 'img[src="http://example.com"]'
    end
  end
end
