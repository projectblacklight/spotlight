# frozen_string_literal: true

RSpec.describe Spotlight::SolrDocumentLegacyEmbedComponent, type: :component do
  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:document) { SolrDocument.new(id: 'abc123') }
  let(:presenter) { Blacklight::DocumentPresenter.new(document, vc_test_controller.view_context, blacklight_config) }

  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
  end

  it 'renders as a collection' do
    expect { render_inline(described_class.with_collection([presenter])) }.not_to raise_error
  end
end
