# frozen_string_literal: true

class TestMetadataClass
  def initialize(*); end

  def to_solr
    { 'test_field' => 'metadata-to-solr' }
  end

  def label; end
end

RSpec.describe Spotlight::Resources::IiifManifestV3 do
  subject { described_class.new(url:, manifest:, collection:) }

  let(:url) { 'uri://to-manifest' }

  let(:collection) { double(compound_id: '1') }
  let(:manifest_fixture) { test_v3_manifest }

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
      it 'is included in the solr document when present' do
        expect(subject.to_solr['full_title_tesim']).to eq 'A Map of the British and French settlements in North America'
      end

      it 'indexes to multiple fields when configured' do
        allow(Spotlight::Engine.config).to receive(:iiif_title_fields).at_least(:once).and_return(%w[title_field1 title_field2])

        expect(subject.to_solr['title_field1']).to eq 'A Map of the British and French settlements in North America'
        expect(subject.to_solr['title_field2']).to eq 'A Map of the British and French settlements in North America'
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
        expect(subject.to_solr[:thumbnail_url_ssm]).to eq ['uri://to-thumbnail']
      end
    end

    describe 'full size image url' do
      it 'is included in the solr document' do
        expect(subject.to_solr[:full_image_url_ssm]).to eq 'https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file'
      end
    end

    describe 'info url' do
      it 'is included in the solr document when present' do
        expect(subject.to_solr[:content_metadata_image_iiif_info_ssm]).to eq ['https://iiif-cloud.example.org/iiif/2/for-v3-manifest/image-1/intermediate_file/info.json']
      end
    end

    describe 'metadata' do
      it 'includes the top-level attribution' do
        expect(subject.to_solr['readonly_attribution_tesim']).to eq [
          '<span>Glen Robson, IIIF Technical Coordinator. <a href="https://creativecommons.org/licenses/by-sa/3.0">CC BY-SA 3.0</a>'
        ]
      end

      it 'includes the top-level description' do
        expect(subject.to_solr['readonly_description_tesim']).to eq [
          'Relief shown pictorially.',
          'From the Universal magazine of knowledge and pleasure. v. 17, Oct. 1755, p. 144-145.',
          'Inset: Fort Frederick at Crown Point built by the French, 1731.'
        ]
      end

      it 'includes the top-level license' do
        expect(subject.to_solr['readonly_license_tesim']).to eq ['http://rightsstatements.org/vocab/NKC/1.0/']
      end

      it 'includes fields for each label/value pair in the metadata section' do
        expect(subject.to_solr['readonly_contributor_tesim']).to include 'Hinton, John, d. 1781'
        expect(subject.to_solr['readonly_cartographic-scale_tesim']).to eq ['Scale [ca. 1:10,000,000].']
      end

      it 'collects items with the same label into an array' do
        expect(subject.to_solr['readonly_call-number_tesim']).to eq ['HMC01.1058', 'Electronic Resource']
      end

      it 'exhibit custom fields are created for the necessary fields' do
        expect { subject.to_solr }.to change(Spotlight::CustomField, :count).by(8)
      end

      it 'creates read-only custom fields' do
        expect { subject.to_solr }.to change(Spotlight::CustomField.where(readonly_field: true), :count).by(8)
      end

      context 'custom class' do
        before do
          allow(Spotlight::Engine.config).to receive(:iiif_metadata_class).and_return(-> { TestMetadataClass })
        end

        it 'merges the solr hash from the configured custom metadata class' do
          expect(subject.to_solr['readonly_test_field_tesim']).to eq 'metadata-to-solr'
        end
      end
    end

    context 'with a multilingual manifest' do
      let(:manifest_fixture) { test_multilingual_v3_manifest }

      describe 'label' do
        it 'is included in the solr document when present' do
          expect(subject.to_solr['full_title_tesim']).to eq "Whistler's Mother"
        end
      end

      describe 'metadata' do
        it 'extracts labels and values out of multivalued data and removes HTML markup' do
          expect(subject.to_solr).to include 'readonly_creator_tesim' => ['Whistler, James Abbott McNeill'],
                                             'readonly_subject_tesim' => ['McNeill Anna Matilda, mother of Whistler (1804-1881)']
        end

        it 'extracts data using the configured default language' do
          allow(Spotlight::Engine.config).to receive(:default_json_ld_language).and_return('fr')
          expect(subject.to_solr).to include 'readonly_auteur_tesim' => ['Whistler, James Abbott McNeill'],
                                             'readonly_sujet_tesim' => ['McNeill Anna Matilda, mère de Whistler (1804-1881)']
        end

        it 'falls back to a language from the manifest using the IIIF rules' do
          allow(Spotlight::Engine.config).to receive(:default_json_ld_language).and_return('de')
          expect(subject.to_solr).to include 'readonly_creator_tesim' => ['Whistler, James Abbott McNeill'],
                                             'readonly_subject_tesim' => ['McNeill Anna Matilda, mother of Whistler (1804-1881)']
        end
      end
    end
  end
end
