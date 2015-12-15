require 'spec_helper'

describe Spotlight::Resources::OpenGraph, type: :model do
  class TestResource < Spotlight::Resource
    include Spotlight::Resources::Web
    include Spotlight::Resources::OpenGraph
  end

  let(:exhibit) { double(solr_data: {}, blacklight_config: Blacklight::Configuration.new) }

  subject { TestResource.new url: 'info:url' }

  describe '#to_solr' do
    before do
      allow(subject).to receive_messages id: 15, opengraph_properties: {}, exhibit: exhibit, persisted?: true
    end

    let(:solr_doc) { subject.to_solr }

    it 'includes this record id' do
      expect(solr_doc).to include spotlight_resource_id_ssim: subject.to_global_id.to_s
    end

    it 'includes opengraph properties' do
      allow(subject).to receive_messages opengraph_properties: { a: 1, b: 2 }

      expect(solr_doc).to include a: 1, b: 2
    end
  end

  describe '#opengraph_properties' do
    it 'maps opengraph properties to solr fields' do
      allow(subject).to receive_messages opengraph: { 'og_title' => 'title', 'og_description' => 'description' }
      expect(subject.opengraph_properties).to include 'og_title_tesim' => 'title', 'og_description_tesim' => 'description'
    end
  end

  describe '#opengraph' do
    let(:body) do
      Nokogiri::HTML.parse <<-EOF
        <html><head>
        <meta property="og:title" content="The Ground Truth: The Human Cost of War"/>
        <meta property="og:description" content="The Ground Truth: The Human Cost of War is our soldiers' perspective of the Iraq War"/>
        <meta property="og:type" content="video.movie"/>
        <meta property="og:site_name" content="Internet Archive"/>
        <meta property="og:video" content="https://archive.org/download/Ground_Truth/GroundTruth1_bb_512kb.mp4"/>
        <meta property="og:video:width" content="320"/>
        <meta property="og:video:height" content="240"/>
        </head></html>
      EOF
    end
    it 'extracts opengraph <meta> tags' do
      allow(subject).to receive_messages(body: body)
      expect(subject.opengraph).to include 'og:title', 'og:description', 'og:type', 'og:type', 'og:site_name', 'og:video', 'og:video:width', 'og:video:height'
      expect(subject.opengraph['og:title']).to eq 'The Ground Truth: The Human Cost of War'
    end
  end
end
