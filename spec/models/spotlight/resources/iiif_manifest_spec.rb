# frozen_string_literal: true

require 'spec_helper'

class TestMetadataClass
  def initialize(*); end

  def to_solr
    { 'test_field' => 'metadata-to-solr' }
  end
end

describe Spotlight::Resources::IiifManifest do
  let(:url) { 'uri://to-manifest' }
  subject { described_class.new(url: url, manifest: manifest, collection: collection) }
  let(:collection) { double(compound_id: '1') }
  let(:manifest_fixture) { test_manifest1 }
  before do
    stub_iiif_response_for_url(url, manifest_fixture)
    subject.with_exhibit(exhibit)
  end

  describe '#to_solr' do
    let(:manifest) { Spotlight::Resources::IiifService.new(url).send(:object) }
    let(:exhibit) { FactoryBot.create(:exhibit) }
    describe 'id' do
      it 'is an MD5 hexdigest of the exhibit id and the and the url' do
        expected = Digest::MD5.hexdigest("#{exhibit.id}-#{url}")
        expect(subject.to_solr[:id]).to eq expected
      end
    end

    describe 'label' do
      it 'is inlcuded in the solr document when present' do
        expect(subject.to_solr['full_title_tesim']).to eq 'Test Manifest 1'
      end

      it 'indexes to multiple fields when configured' do
        allow(Spotlight::Engine.config).to receive(:iiif_title_fields).at_least(:once).and_return(%w(title_field1 title_field2))

        expect(subject.to_solr['title_field1']).to eq 'Test Manifest 1'
        expect(subject.to_solr['title_field2']).to eq 'Test Manifest 1'
      end
    end

    context 'JSON-LD style labels' do
      context 'when it is an array' do
        let(:manifest_fixture) { test_manifest3 }

        it 'uses the configured language to find a value' do
          expect(subject.to_solr['full_title_tesim']).to eq 'Test Manifest 3'

          allow(Spotlight::Engine.config).to receive(:default_json_ld_language).and_return('fr')
          expect(subject.to_solr['full_title_tesim']).to eq "Manifeste d'essai 3"
        end
      end

      context 'when it is a hash' do
        let(:manifest_fixture) { test_manifest2 }

        it 'is parsed correctly' do
          expect(subject.to_solr['full_title_tesim']).to eq 'Test Manifest 2'
        end
      end
    end

    describe 'collection id' do
      it 'is included when a collection is given' do
        expect(subject.to_solr[:collection_id_ssim]).to eq ['1']
      end
    end

    describe 'manifest url' do
      it 'is inlcuded in the solr document when present' do
        expect(subject.to_solr[:iiif_manifest_url_ssi]).to eq url
      end
    end

    describe 'thumbnail url' do
      it 'is inlcuded in the solr document when present' do
        expect(subject.to_solr[:thumbnail_url_ssm]).to eq 'uri://to-thumbnail'
      end
    end

    describe 'full size image url' do
      it 'is included in the solr document' do
        expect(subject.to_solr[:full_image_url_ssm]).to eq 'uri://full-image'
      end
    end

    describe 'image urls' do
      it 'is included in the solr document when present' do
        expect(subject.to_solr[:content_metadata_image_iiif_info_ssm]).to eq ['uri://to-image-service/info.json']
      end
    end

    describe 'metadata' do
      it 'includes the top-level attribution' do
        expect(subject.to_solr['readonly_attribution_tesim']).to eq ['Attribution Data']
      end

      it 'includes the top-level description' do
        expect(subject.to_solr['readonly_description_tesim']).to eq ['A test IIIF manifest']
      end

      it 'includes the top-level license' do
        expect(subject.to_solr['readonly_license_tesim']).to eq ['http://www.example.org/license.html']
      end

      it 'includes fields for each label/value pair in the metadata section' do
        expect(subject.to_solr['readonly_author_tesim']).to include 'John Doe'
        expect(subject.to_solr['readonly_another-field_tesim']).to eq ['Some data']
      end

      it 'collects items with the same label into an array' do
        expect(subject.to_solr['readonly_author_tesim']).to eq ['John Doe', 'Jane Doe']
      end

      it 'exhibit custom fields are created for the necessary fields' do
        expect { subject.to_solr }.to change(Spotlight::CustomField, :count).by(5)
      end

      it 'creates read-only custom fields' do
        expect { subject.to_solr }.to change(Spotlight::CustomField.where(readonly_field: true), :count).by(5)
      end

      context 'custom class' do
        before do
          Spotlight::Engine.config.iiif_metadata_class = -> { TestMetadataClass }
        end

        it 'merges the solr hash from the configured custom metadata class' do
          expect(subject.to_solr['readonly_test_field_tesim']).to eq 'metadata-to-solr'
        end
      end
    end
  end
end
