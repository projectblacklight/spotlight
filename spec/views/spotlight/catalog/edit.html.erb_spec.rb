require 'spec_helper'

describe "spotlight/catalog/edit.html.erb", :type => :view do
  let(:blacklight_config) { Blacklight::Configuration.new }

  let(:document) { stub_model(::SolrDocument) }

  before do
    allow(view).to receive_messages(blacklight_config: blacklight_config)
    allow(view).to receive_messages(current_exhibit: stub_model(Spotlight::Exhibit))
    assign(:document, document)
  end

  before do
    allow(view).to receive_messages(current_page?: true)
    allow(view).to receive(:document_show_html_title)
    allow(view).to receive(:edit_exhibit_catalog_path)
  end
end



