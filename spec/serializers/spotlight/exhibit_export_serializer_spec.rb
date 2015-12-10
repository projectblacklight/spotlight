require 'spec_helper'

describe Spotlight::ExhibitExportSerializer do
  let!(:source_exhibit) { FactoryGirl.create(:exhibit) }

  before do
    allow_any_instance_of(Spotlight::Search).to receive(:set_default_featured_image)
    allow_any_instance_of(SolrDocument).to receive(:reindex)
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
  end

  subject { JSON.parse(described_class.new(source_exhibit).to_json) }

  it 'does not include unique identifiers' do
    expect(subject).to_not have_key 'id'
    expect(subject).to_not have_key 'slug'
    expect(subject).to_not have_key 'name'
    expect(subject).to_not have_key 'default'
    expect(subject).to_not have_key 'masthead_id'
    expect(subject).to_not have_key 'thumbnail_id'
  end

  it 'has search attributes' do
    expect(subject['searches']).to have(source_exhibit.searches.count).searches
  end

  it 'has home page attributes' do
    expect(subject).to have_key 'home_page'
    expect(subject['home_page']).to_not have_key 'id'
    expect(subject['home_page']).to_not have_key 'scope'
    expect(subject['home_page']).to_not have_key 'exhibit_id'
  end

  it 'has about pages' do
    expect(subject['about_pages']).to have(source_exhibit.about_pages.count).pages
  end

  it 'has feature pages' do
    expect(subject['feature_pages']).to have(source_exhibit.feature_pages.at_top_level.count).pages
  end

  it 'has custom fields' do
    expect(subject['custom_fields']).to have(source_exhibit.custom_fields.count).items
  end

  it 'has contact emails' do
    expect(subject['contact_emails']).to have(source_exhibit.contact_emails.count).items
  end

  it 'has blacklight configuration attributes' do
    expect(subject).to have_key 'blacklight_configuration'
  end

  it 'has solr document sidecars' do
    source_exhibit.solr_document_sidecars.create! document: SolrDocument.new(id: 1), public: false
    expect(subject['solr_document_sidecars']).to have_at_least(1).item
    expect(subject['solr_document_sidecars']).to have(source_exhibit.solr_document_sidecars.count).items

    expect(subject['solr_document_sidecars'].first).to include('document_id', 'public')
    expect(subject['solr_document_sidecars'].first).to_not include 'id'
  end

  it 'has attachments' do
    expect(subject['attachments']).to have(source_exhibit.attachments.count).items
  end

  it 'has resources' do
    expect(subject['resources']).to have(source_exhibit.resources.count).items
  end

  it 'has tags' do
    source_exhibit.tag(SolrDocument.new(id: 1), with: 'xyz', on: :tags)
    expect(subject['owned_taggings']).to have(source_exhibit.owned_taggings.count).items
  end

  describe 'should round-trip data' do
    before do
      source_exhibit.solr_document_sidecars.create! document: SolrDocument.new(id: 1), public: false
      source_exhibit.tag(SolrDocument.new(id: 1), with: 'xyz', on: :tags)
    end

    let :export do
      described_class.new(source_exhibit).as_json
    end

    subject do
      e = FactoryGirl.create(:exhibit)
      e.import(export).tap(&:save)
    end

    it 'has exhibit properties' do
      expect(subject.title).to eq source_exhibit.title
    end

    it 'does not duplicate saved searches' do
      expect(subject.searches).to have(1).item
    end

    it 'has blacklight configuration properties' do
      expect(subject.blacklight_configuration).to be_persisted
    end

    context 'for an exhibit without search fields' do
      before do
        source_exhibit.blacklight_configuration.search_fields = {}
        source_exhibit.blacklight_configuration.save
      end

      it 'remains without search fields' do
        expect(subject.blacklight_configuration.search_fields).to be_blank
      end
    end

    it 'has home page properties' do
      expect(subject.home_page).to be_persisted
      expect(subject.home_page.id).not_to eq source_exhibit.home_page.id

      expect(subject.home_page.title).to eq source_exhibit.home_page.title
      expect(subject.home_page.content).to eq source_exhibit.home_page.content
    end

    it 'has sidecars' do
      expect(SolrDocument.new(id: 1).public? subject).to be_falsey
    end

    context 'for an exhibit with contacts' do
      let!(:curator) do
        FactoryGirl.create(:contact,
                           exhibit: source_exhibit,
                           contact_info: { title: 'xyz' })
      end
      it 'has contacts' do
        expect(subject.contacts.count).to eq 1
        contact = subject.contacts.first
        expect(contact.contact_info[:title]).to eq 'xyz'
      end

      describe 'for a contact without an avatar' do
        let!(:curator) do
          FactoryGirl.create(:contact, exhibit: source_exhibit, avatar: nil)
        end

        it 'has contacts' do
          expect(subject.contacts.count).to eq 1
        end
      end
    end

    it 'has tags' do
      expect(subject.owned_taggings.length).to eq source_exhibit.owned_taggings.length
      expect(subject.owned_taggings.first).to be_persisted
      expect(subject.owned_taggings.first.tag.name).to eq 'xyz'
    end

    context 'with custom main navigation labels' do
      before do
        nav = source_exhibit.main_navigations.about
        nav.label = 'Custom Label'
        nav.save
      end

      it 'persists across import/export' do
        expect(subject.main_navigations.about.label).to eq 'Custom Label'
      end
    end

    it 'has tags' do
      expect(subject.owned_taggings.length).to eq source_exhibit.owned_taggings.length
      expect(subject.owned_taggings.first).to be_persisted
      expect(subject.owned_taggings.first.tag.name).to eq 'xyz'
    end

    it 'deals with nested feature pages' do
      FactoryGirl.create :feature_subpage, exhibit: source_exhibit
      expect(subject.feature_pages.at_top_level.length).to eq 1
      expect(subject.feature_pages.first.child_pages.length).to eq 1
    end

    context 'page slugs' do
      let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: source_exhibit, slug: 'xyz') }

      it 'uses the existing slug for the page' do
        expect(subject.feature_pages.find('xyz')).to be_persisted
      end
    end

    context 'with a feature page' do
      let(:feature_page) { FactoryGirl.create(:feature_page, exhibit: source_exhibit) }
      let(:thumbnail) { FactoryGirl.create(:featured_image) }

      before do
        feature_page.content = { data: [{ type: 'text', data: { text: 'xyz' } }] }.to_json
        feature_page.thumbnail = thumbnail
        feature_page.save
      end

      it 'copies the masthead' do
        expect(subject.feature_pages.first.thumbnail).not_to be_blank
        expect(subject.feature_pages.first.thumbnail.image.file.path).not_to eq feature_page.thumbnail.image.file.path
      end

      it 'copies the thumbnail' do
        expect(subject.feature_pages.first.thumbnail).not_to be_blank
        expect(subject.feature_pages.first.thumbnail.image.file.path).not_to eq source_exhibit.feature_pages.first.thumbnail.image.file.path
      end

      it 'copies the content' do
        expect(JSON.parse(subject.feature_pages.first.read_attribute(:content))).to have_key 'data'
        expect(subject.feature_pages.first.content.length).to eq 1
        expect(subject.feature_pages.first.content.first).to be_a_kind_of SirTrevorRails::Blocks::TextBlock
      end
    end

    it 'assigns STI resources the correct class' do
      resource = FactoryGirl.create :uploaded_resource, exhibit: source_exhibit
      expect(subject.resources.length).to eq 1
      expect(subject.resources.first.class).to eq Spotlight::Resources::Upload
      expect(subject.resources.first.url.file.path).not_to eq resource.url.file.path
    end

    it 'assigns normal resources the correct class' do
      resource = FactoryGirl.create :resource, exhibit: source_exhibit
      expect(subject.resources.length).to eq 1
      expect(subject.resources.first.class).to eq Spotlight::Resource
      expect(subject.resources.first.url).to eq resource.url
    end

    it 'copies contact avatars' do
      contact = FactoryGirl.create :contact, exhibit: source_exhibit
      expect(subject.contacts.length).to eq 1
      expect(subject.contacts.first.avatar.file.path).not_to eq contact.avatar.file.path
    end

    context 'with a browse category' do
      let(:masthead) { FactoryGirl.create(:masthead) }
      let(:thumbnail) { FactoryGirl.create(:featured_image) }
      let!(:search) { FactoryGirl.create(:search, exhibit: source_exhibit, masthead: masthead, thumbnail: thumbnail) }

      before do
        source_exhibit.reload
      end

      it 'copies the masthead' do
        expect(subject.searches.last.masthead).not_to be_blank
        expect(subject.searches.last.masthead.image.file.path).not_to eq search.masthead.image.file.path
      end

      it 'copies the thumbnail' do
        expect(subject.searches.first.thumbnail).not_to be_blank
        expect(subject.searches.first.thumbnail.image.file.path).not_to eq search.thumbnail.image.file.path
      end

      context 'without an attached image' do
        before do
          search.masthead.remove_image!
          search.masthead.save
        end

        it 'copies the masthead without an image' do
          expect(subject.searches.last.masthead).not_to be_blank
          expect(subject.searches.last.masthead.image).to be_blank
        end
      end

      context 'with a thumbnail from an uploaded resource' do
        before do
          search.masthead.document_global_id = SolrDocument.new(id: 'xyz').to_global_id
          search.masthead.source = 'exhibit'
          search.masthead.save

          source_exhibit.reload
        end

        it 'copies the resource' do
          expect(subject.searches.last.masthead).not_to be_blank
        end
      end
    end

    context 'with a masthead' do
      let!(:masthead) { FactoryGirl.create(:masthead) }

      before do
        source_exhibit.masthead = masthead
      end

      it 'is copied' do
        expect(subject.masthead).not_to be_blank
        expect(subject.masthead.image.file.path).not_to eq source_exhibit.masthead.image.file.path
      end
    end

    context 'with a thumbnail' do
      let!(:thumbnail) { FactoryGirl.create(:featured_image) }

      before do
        source_exhibit.thumbnail = thumbnail
      end

      it 'is copied' do
        expect(subject.thumbnail).not_to be_blank
        expect(subject.thumbnail.image.file.path).not_to eq source_exhibit.thumbnail.image.file.path
      end
    end
  end

  it 'is idempotent-ish' do
    FactoryGirl.create :feature_subpage, exhibit: source_exhibit
    export = described_class.new(source_exhibit).as_json
    e = FactoryGirl.create(:exhibit)
    e.import(export).tap(&:save)
    e.import(export).tap(&:save)
  end

  describe 'should export saved searches with query parameters that can be re-generated' do
    before do
      source_exhibit.feature_pages.create content: [{
        type: 'search_results',
        data: {
          'item' => {
            search.slug => { id: search.slug, display: 'true' }
          },
          view: ['list']
        }
      }].to_json
    end

    subject do
      e = FactoryGirl.create(:exhibit)
      e.import(export).tap(&:save)
    end

    let :export do
      described_class.new(source_exhibit).as_json
    end

    context 'with a search object with matching query params' do
      let :search do
        source_exhibit.searches.first
      end

      it 'uses a search within the exhibit' do
        # searches need to be published.
        subject.searches.each { |x| x.update published: true }

        expect(subject.feature_pages.first.content.first.search.exhibit).to eq subject
      end

      it 'uses the existing search object with the same query params' do
        expect(subject.searches).to have(1).item
      end
    end

    context 'with a search object that needs to be created' do
      let :search do
        source_exhibit.searches.create title: 'custom query', slug: 'xyz', published: true
      end

      before do
        allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
      end

      it 'creates a search within the exhibit' do
        expect(subject.feature_pages.first.content.first.search.exhibit).to eq subject
      end

      it 'uses the existing search object with the same query params' do
        expect(subject.searches).to have(2).items
      end
    end
  end
end
