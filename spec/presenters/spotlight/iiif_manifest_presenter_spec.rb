# frozen_string_literal: true

describe Spotlight::IiifManifestPresenter do
  require 'iiif_manifest'

  let(:resource) { SolrDocument.new(id: '1-1') }
  let(:uploaded_resource) { FactoryBot.build(:uploaded_resource) }
  let(:controller) { double(Spotlight::CatalogController) }

  let(:subject) { described_class.new(resource, controller) }

  let(:profile_url) { 'http://iiif.io/api/image/2/level2.json' }

  before do
    allow(resource).to receive(:uploaded_resource).and_return(uploaded_resource)
  end

  describe 'public methods' do
    let(:iiif_url) { 'https://iiif.test/images/1-1' }
    let(:endpoint) { IIIFManifest::IIIFEndpoint.new(iiif_url, profile: profile_url) }
    let(:manifest_url) { 'https://iiif.test/spotlight/test/catalog/1-1/manifest' }
    let(:spotlight_route_helper) { double }
    let(:blacklight_config) { double(Spotlight::BlacklightConfiguration) }

    let(:id) { 123 }
    let(:title_field_name) { 'title_field_name' }
    let(:title_field_value) { 'title' }
    let(:description_field_value) { 'description' }
    let(:img_width) { 11 }
    let(:img_height) { 10 }

    before do
      allow(spotlight_route_helper).to receive(:manifest_exhibit_solr_document_url).with(uploaded_resource.exhibit, resource).and_return(manifest_url)
      allow(controller).to receive(:spotlight).and_return(spotlight_route_helper)

      allow(blacklight_config).to receive(:view_config).with(:show).and_return(double(title_field: title_field_name))
      allow(controller).to receive(:blacklight_config).and_return(blacklight_config)

      allow(resource).to receive(:first).with(title_field_name).and_return(title_field_value)
      allow(resource).to receive(:first).with(Spotlight::Engine.config.upload_description_field).and_return(description_field_value)
      allow(resource).to receive(:first).with(:spotlight_full_image_width_ssm).and_return(img_width)
      allow(resource).to receive(:first).with(:spotlight_full_image_height_ssm).and_return(img_height)

      allow(subject).to receive(:endpoint).and_return(endpoint)
      allow(subject).to receive(:id).and_return(id)
    end

    describe '#display_image' do
      it 'returns a properly configured instance of IIIFManifest::DisplayImage' do
        # can't do:
        #   expect(subject.display_image).to eq(IIIFManifest::DisplayImage.new(0, width: 10, height: 10, format: 'image/jpeg', iiif_endpoint: endpoint))
        # because IIIFManifest::DisplayImage doesn't implement #==
        result = subject.display_image
        expect(result.url).to eq id
        expect(result.width).to eq img_width
        expect(result.height).to eq img_height
        expect(result.format).to eq 'image/jpeg'
        expect(result.iiif_endpoint).to eq endpoint
      end
    end

    describe '#file_set_presenters' do
      it "returns a single-element list containing the presenter object on which it's called" do
        expect(subject.file_set_presenters).to eq([subject])
      end
    end

    describe '#work_presenters' do
      it "returns an empty list, because we don't yet support interstitial nodes in the document manifest" do
        expect(subject.work_presenters).to eq([])
      end
    end

    describe '#manifest_url' do
      it 'relays the value from the spotlight route url helper' do
        expect(subject.manifest_url).to eq(manifest_url)
      end
    end

    describe '#description' do
      it 'gets the description from the resource using the configured upload_description_field' do
        expect(subject.description).to eq(description_field_value)
      end
    end

    describe '#to_s' do
      it "uses the resource's title field value as the presenter's string representation" do
        expect(subject.to_s).to eq(title_field_value)
      end
    end

    describe '#iiif_manifest' do
      it 'builds a IIIFManifest object based on the presenter object info' do
        result = subject.iiif_manifest
        expect(result).to be_an_instance_of(IIIFManifest::ManifestBuilder)
        expect(result.work).to be(subject)
      end
    end

    describe '#iiif_manifest_json' do
      it 'returns json for the manifest generated from the presenter object info' do
        expect(subject.iiif_manifest_json).to eq(subject.iiif_manifest.to_h.to_json)
      end
    end
  end

  describe 'private methods' do
    describe '#endpoint' do
      it 'returns a properly configured instance of IIIFManifest::IIIFEndpoint' do
        iiif_url = 'https://iiif.test/images/1-1'
        allow(subject).to receive(:iiif_url).and_return(iiif_url)

        result = subject.send(:endpoint)
        expect(result.url).to eq(iiif_url)
        expect(result.profile).to eq(profile_url)
      end
    end

    describe '#iiif_url' do
      it 'returns the info_url from the Riiif engine routes, minus the trailing .json' do
        riiif_route_helper = double(info_url: 'https://iiif.test/path/info.json')
        allow(controller).to receive(:riiif).and_return(riiif_route_helper)

        expect(subject.send(:iiif_url)).to eq('https://iiif.test/path')
      end
    end
  end
end
