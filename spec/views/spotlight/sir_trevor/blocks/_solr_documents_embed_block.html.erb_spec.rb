# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_solr_documents_embed_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_embed_block' }
  let(:page) { double('Page') }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsEmbedBlock.new({ type: 'block', data: { title: 'Some title', text: 'Some text', 'text-align' => 'right' } }, page)
  end
  let(:doc) { blacklight_config.document_model.new(id: 1) }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.view.embed(
        document_component: Spotlight::SolrDocumentLegacyEmbedComponent,
        partials: %w[a b c],
        locals: { a: 1 }
      )
    end
  end
  let(:stub_presenter) do
    instance_double(Blacklight::DocumentPresenter, document: doc, heading: 'blah',
                                                   thumbnail: thumbnail_presenter,
                                                   view_config: blacklight_config.view.embed,
                                                   field_presenters: [],
                                                   display_type: nil)
  end

  let(:thumbnail_presenter) { instance_double(Blacklight::ThumbnailPresenter, exists?: true, thumbnail_tag: 'thumb') }

  before do
    allow(block).to receive(:each_document).and_yield({}, doc)
    allow(block).to receive(:documents?).and_return(true)
    allow(view).to receive_messages(blacklight_config:, document_presenter: stub_presenter)
  end

  it 'has a embed block' do
    expect(view).to receive(:render_document_partials).with(doc, %w[a b c], hash_including(a: 1, block:)).and_return('OSD')
    render partial: p, locals: { solr_documents_embed_block: block }
    expect(rendered).to have_selector 'h3', text: 'Some title'
    expect(rendered).to have_content 'Some text'
    expect(rendered).to have_selector '.box', text: 'OSD'
    expect(rendered).to have_selector '.items-col'
    expect(rendered).to have_selector '.text-col'
    expect(rendered).to have_no_selector '.col-md-12'
  end

  context 'with a block with no text' do
    let(:block) do
      SirTrevorRails::Blocks::SolrDocumentsEmbedBlock.new({ type: 'block', data: { title: 'Some title', 'text-align' => 'right' } }, page)
    end

    it 'does not have a two column layout' do
      expect(view).to receive(:render_document_partials).with(doc, %w[a b c], hash_including(a: 1, block:)).and_return('OSD')
      render partial: p, locals: { solr_documents_embed_block: block }
      expect(rendered).to have_selector '.col-md-12'
      expect(rendered).to have_selector '.items-col h3', text: 'Some title'
    end
  end
end
