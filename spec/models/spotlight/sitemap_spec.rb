require 'spec_helper'
require 'sitemap_generator'

describe Spotlight::Sitemap do
  let(:sitemap) { SitemapGenerator::Interpreter.new }
  let(:exhibit) { FactoryGirl.create(:exhibit, published: true) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:sitemap_content) { sitemap.sitemap.sitemap.instance_variable_get(:@xml_content) }
  let(:url_helpers) { Spotlight::Engine.routes.url_helpers }

  subject { described_class.new(sitemap, exhibit) }

  before do
    allow(exhibit).to receive(:blacklight_config).and_return(blacklight_config)

    SitemapGenerator::Sitemap.default_host = 'http://localhost/'
    SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
    SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers
  end

  describe '.add_all_exhibits' do
    let!(:second_exhibit) { FactoryGirl.create(:exhibit, published: true) }
    let!(:unpublished_exhibit) { FactoryGirl.create(:exhibit, published: false) }

    it 'builds a sitemap for all published exhibits' do
      sitemaps = []

      allow_any_instance_of(described_class).to receive(:add_resources!) do |s|
        sitemaps << s
      end

      described_class.add_all_exhibits(sitemap)

      expect(sitemaps.map(&:exhibit)).to include exhibit, second_exhibit
      expect(sitemaps.map(&:exhibit)).not_to include unpublished_exhibit
    end
  end

  describe '.add_exhibit' do
    it 'builds a sitemap for the exhibit' do
      expect_any_instance_of(described_class).to receive(:add_resources!)

      described_class.add_exhibit(sitemap, exhibit)
    end
  end

  describe '#add_resources!' do
    it 'builds a sitemap for all exhibit resources' do
      expect(subject).to receive(:add_exhibit_root)
      expect(subject).to receive(:add_pages)
      expect(subject).to receive(:add_resources)
      expect(subject).to receive(:add_browse_categories)

      subject.add_resources!
    end

    it 'does not publish sitemaps for unpublished exhibits' do
      exhibit.published = false

      expect(subject).not_to receive(:add_exhibit_root)
      expect(subject).not_to receive(:add_pages)
      expect(subject).not_to receive(:add_resources)
      expect(subject).not_to receive(:add_browse_categories)

      subject.add_resources!
    end
  end

  describe '#add_exhibit_root' do
    it 'adds the home page' do
      subject.add_exhibit_root
      expect(sitemap_content).to include url_helpers.exhibit_root_path(exhibit)
    end
  end

  describe '#add_pages' do
    let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit, published: true) }
    let!(:about_page) { FactoryGirl.create(:about_page, exhibit: exhibit, published: true) }

    it 'adds feature pages' do
      subject.add_pages
      expect(sitemap_content).to include url_helpers.exhibit_feature_page_path(exhibit, feature_page)
    end

    it 'adds about pages' do
      subject.add_pages
      expect(sitemap_content).to include url_helpers.exhibit_about_page_path(exhibit, about_page)
    end
  end

  describe '#add_resources' do
    let(:document) { blacklight_config.document_model.new(id: 'a') }

    before do
      allow(exhibit).to receive(:solr_documents).and_return([document])
    end

    it 'adds document resources' do
      subject.add_resources
      expect(sitemap_content).to include url_helpers.exhibit_solr_document_path(exhibit, document)
    end
  end

  describe '#add_browse_categories' do
    let!(:search) { FactoryGirl.create(:published_search, exhibit: exhibit) }

    it 'adds browse categories to the sitemap' do
      subject.add_browse_categories
      expect(sitemap_content).to include url_helpers.exhibit_browse_path(exhibit, search)
    end
  end
end
