require 'spec_helper'

describe Spotlight::BrowseHelper, type: :helper do
  it 'defaults to the gallery' do
    allow(helper).to receive_messages(blacklight_config: double(view: { gallery: true }))
    expect(helper.default_document_index_view_type).to eq :gallery
  end

  it "uses the blacklight default if gallery isn't available" do
    allow(helper).to receive_messages(blacklight_config: double(view: { list: true }))
    expect(helper.default_document_index_view_type).to eq :list
  end
end
