require 'spec_helper'

describe Spotlight::Exhibit, type: :model do
  subject { FactoryGirl.build(:exhibit, title: 'Sample') }

  it 'has a title' do
    subject.title = 'Test title'
    expect(subject.title).to eq 'Test title'
  end

  it 'has a subtitle' do
    subject.subtitle = 'Test subtitle'
    expect(subject.subtitle).to eq 'Test subtitle'
  end

  it 'has a description that strips html tags' do
    subject.description = 'Test <b>description</b>'
    subject.save!
    expect(subject.description).to eq 'Test description'
  end
  describe 'contact_emails' do
    before do
      subject.contact_emails_attributes = [{ 'email' => 'chris@example.com' }, { 'email' => 'jesse@stanford.edu' }]
    end
    it 'accepts nested contact_emails' do
      expect(subject.contact_emails.size).to eq 2
    end
  end

  it 'has a #to_s' do
    expect(subject.to_s).to eq 'Sample'
    subject.title = 'New Title'
    expect(subject.to_s).to eq 'New Title'
  end

  describe 'that is saved' do
    before { subject.save! }

    it 'has a configuration' do
      expect(subject.blacklight_configuration).to be_kind_of Spotlight::BlacklightConfiguration
    end

    it 'has an unpublished search' do
      expect(subject.searches).to have(1).search
      expect(subject.searches.published).to be_empty
      expect(subject.searches.first.query_params).to be_empty
    end
  end

  context 'thumbnail' do
    it 'calls DefaultThumbnailJob to fetch a default feature image' do
      expect(Spotlight::DefaultThumbnailJob).to receive(:perform_later).with(subject.searches.first)
      expect(Spotlight::DefaultThumbnailJob).to receive(:perform_later).with(subject)
      subject.save!
    end

    context '#set_default_thumbnail' do
      before { subject.save! }
      it 'uses the thubmnail from the first search' do
        subject.set_default_thumbnail
        expect(subject.thumbnail).not_to be_nil
        expect(subject.thumbnail).to eq subject.searches.first.thumbnail
      end
    end
  end

  describe '#main_navigations' do
    subject { FactoryGirl.create(:exhibit, title: 'Sample') }
    it 'has main navigations' do
      expect(subject.main_navigations).to have(3).main_navigations
      expect(subject.main_navigations.map(&:label).compact).to be_blank
      expect(subject.main_navigations.map(&:weight)).to eq [0, 1, 2]
    end
    it "uses the engine's configuration for default navigations" do
      expect(Spotlight::Engine.config).to receive(:exhibit_main_navigation).and_return([:a, :b])
      expect(subject.main_navigations).to have(2).main_navigations
      expect(subject.main_navigations.map(&:nav_type).compact).to match_array %w(a b)
    end
  end

  describe 'contacts' do
    before do
      subject.contacts_attributes = [
        { 'show_in_sidebar' => '0', 'name' => 'Justin Coyne', 'contact_info' => { 'email' => 'jcoyne@justincoyne.com', 'title' => '', 'location' => 'US' } },
        { 'show_in_sidebar' => '0', 'name' => '', 'contact_info' => { 'email' => '', 'title' => 'Librarian', 'location' => '' } }]
    end
    it 'accepts nested contacts' do
      expect(subject.contacts.size).to eq 2
    end
  end

  describe 'import' do
    it 'removes the default browse category' do
      subject.save
      expect { subject.import({}) }.to change { subject.searches.count }.by(0)
      expect { subject.import('searches' => [{ 'title' => 'All Exhibit Items', 'slug' => 'all-exhibit-items' }]) }.to change { subject.searches.count }.by(0)
    end

    it 'imports nested attributes from the hash' do
      subject.save
      subject.import 'title' => 'xyz'
      expect(subject.title).to eq 'xyz'
    end

    it 'munges taggings so they can be imported easily' do
      expect do
        subject.import('owned_taggings' => [{ 'taggable_id' => '1', 'taggable_type' => 'SolrDocument', 'context' => 'tags', 'tag' => 'xyz' }])
        subject.save
      end.to change { subject.owned_taggings.count }.by(1)
      tag = subject.owned_taggings.last
      expect(tag.taggable_id).to eq '1'
      expect(tag.tag.name).to eq 'xyz'
    end
  end

  describe '#blacklight_config' do
    subject { FactoryGirl.create(:exhibit) }
    before do
      subject.blacklight_configuration.index = { timestamp_field: 'timestamp_field' }
      subject.save!
      subject.reload
    end

    it 'creates a blacklight_configuration from the database' do
      expect(subject.blacklight_config.index.timestamp_field).to eq 'timestamp_field'
    end
  end

  describe '#solr_data' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    subject { exhibit.solr_data }

    context 'when not filtering by exhibit' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)
      end

      it 'is blank' do
        expect(subject).to be_blank
      end
    end

    context 'when no filters have been defined' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
      end

      it 'provides a solr field with the exhibit slug' do
        expect(subject).to include("spotlight_exhibit_slug_#{exhibit.slug}_bsi" => true)
      end
    end

    context 'with a filter' do
      before do
        exhibit.filters.create(field: 'orcid_ssim', value: '123')
      end
      it 'uses the provided filter' do
        expect(subject).to include('orcid_ssim' => '123')
      end
    end
  end

  describe '#analytics' do
    subject { FactoryGirl.create(:exhibit) }
    let(:ga_data) { OpenStruct.new(pageviews: 123) }

    before do
      allow(Spotlight::Analytics::Ga).to receive(:enabled?).and_return(true)
      allow(Spotlight::Analytics::Ga).to receive(:exhibit_data).with(subject, hash_including(:start_date)).and_return(ga_data)
    end

    it 'requests analytics data' do
      expect(subject.analytics.pageviews).to eq 123
    end
  end

  describe '#page_analytics' do
    subject { FactoryGirl.create(:exhibit) }
    let(:ga_data) { [OpenStruct.new(pageviews: 123)] }

    before do
      allow(Spotlight::Analytics::Ga).to receive(:enabled?).and_return(true)
      allow(Spotlight::Analytics::Ga).to receive(:page_data).with(subject, hash_including(:start_date)).and_return(ga_data)
    end

    it 'requests analytics data' do
      expect(subject.page_analytics.length).to eq 1
      expect(subject.page_analytics.first.pageviews).to eq 123
    end
  end

  describe '#reindex_later' do
    subject { FactoryGirl.create(:exhibit) }

    it 'queues a reindex job for the exhibit' do
      expect(Spotlight::ReindexJob).to receive(:perform_later).with(subject)
      subject.reindex_later
    end
  end

  describe '#solr_documents' do
    let(:blacklight_config) { Blacklight::Configuration.new }
    let(:slug) { 'some_slug' }
    let(:filter) do
      Spotlight::Filter.new(field: subject.send(:default_filter_field),
                            value: subject.send(:default_filter_value))
    end

    before do
      allow(subject).to receive(:blacklight_config).and_return(blacklight_config)
      allow(subject).to receive(:slug).and_return(slug)
      allow(subject).to receive(:filters).and_return([filter])
    end

    it 'enumerates the documents in the exhibit' do
      expect(subject.solr_documents).to be_a Enumerable
    end

    it 'pages through the index' do
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).and_return(double(documents: [1, 2, 3]))
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(start: 3)).and_return(double(documents: [4, 5, 6]))
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(start: 6)).and_return(double(documents: []))

      expect(subject.solr_documents.to_a).to match_array [1, 2, 3, 4, 5, 6]
    end

    context 'with filter_resources_by_exhibit enabled' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
      end

      it 'filters the solr results using the exhibit filter' do
        expected_query_params = { fq: ["spotlight_exhibit_slug_#{subject.slug}_bsi:true"] }
        allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(expected_query_params)).and_return(double(documents: []))
        expect(subject.solr_documents.to_a).to be_blank
      end
    end

    context 'with filter_resources_by_exhibit disabled' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)
      end

      it 'does not filters the solr results' do
        allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_excluding(fq: [subject.solr_data])).and_return(double(documents: []))
        expect(subject.solr_documents.to_a).to be_blank
      end
    end
  end

  describe '#requested_by' do
    context 'with multiple exhibit users' do
      let!(:exhibit_admin) { FactoryGirl.create(:exhibit_admin, exhibit: subject) }
      let!(:another_exhibit_admin) { FactoryGirl.create(:exhibit_admin, exhibit: subject) }

      it 'is the first listed user' do
        expect(subject.requested_by).to eq exhibit_admin
      end
    end

    context 'if no user has roles on the exhibit' do
      it 'is nil' do
        expect(subject.requested_by).to be_nil
      end
    end
  end

  describe '#reindex_progress' do
    it 'returns a Spotlight::ReindexProgress' do
      expect(subject.reindex_progress).to be_a Spotlight::ReindexProgress
    end
  end
end
