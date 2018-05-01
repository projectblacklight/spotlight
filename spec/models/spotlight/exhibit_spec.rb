describe Spotlight::Exhibit, type: :model do
  subject(:exhibit) { FactoryBot.build(:exhibit, title: 'Sample') }

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

  describe 'validations' do
    it 'validates the presence of the title' do
      exhibit.title = ''
      expect do
        exhibit.save
      end.to change { exhibit.errors[:title].count }.by(1)
    end

    it 'does not validate the presence of the title under a non-default locale' do
      expect(I18n).to receive(:locale).and_return(:fr)
      exhibit.title = ''
      expect do
        exhibit.save
      end.not_to(change { exhibit.errors[:title].count })
    end
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

  describe '#main_navigations' do
    subject { FactoryBot.create(:exhibit, title: 'Sample') }
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
        { 'show_in_sidebar' => '0', 'name' => '', 'contact_info' => { 'email' => '', 'title' => 'Librarian', 'location' => '' } }
      ]
    end
    it 'accepts nested contacts' do
      expect(subject.contacts.size).to eq 2
    end
  end

  describe '#main_about_page' do
    let!(:about_page) { FactoryBot.create(:about_page, exhibit: exhibit, published: false) }
    let!(:about_page2) { FactoryBot.create(:about_page, exhibit: exhibit, published: true) }
    let(:about_page2_es) { about_page2.clone_for_locale('es') }

    it 'is the first published about page' do
      expect(exhibit.main_about_page).to eq about_page2
    end

    describe 'when under a non-default locale' do
      before { I18n.locale = 'es' }
      after { I18n.locale = 'en' }

      it 'loads the first published about page for that locale' do
        about_page2_es.published = true
        about_page2_es.save
        expect(exhibit.main_about_page).to eq about_page2_es
      end

      it 'is nil when there is no locale specific page published' do
        about_page2_es.published = false
        about_page2_es.save
        expect(exhibit.main_about_page).to be_nil
      end
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
  end

  describe '#blacklight_config' do
    subject { FactoryBot.create(:exhibit) }
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
    let(:exhibit) { FactoryBot.create(:exhibit) }
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
    subject { FactoryBot.create(:exhibit) }
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
    subject { FactoryBot.create(:exhibit) }
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
    subject { FactoryBot.create(:exhibit) }
    let(:log_entry) { Spotlight::ReindexingLogEntry.new(exhibit: subject, user: user, items_reindexed_count: 0) }

    context 'user is omitted' do
      let(:user) { nil }

      it 'queues a reindex job for the exhibit, with nil user for the log entry' do
        expect(subject).to receive(:new_reindexing_log_entry).with(nil).and_return(log_entry)
        expect(Spotlight::ReindexJob).to receive(:perform_later).with(subject, log_entry)
        subject.reindex_later
        expect(log_entry.user).to be nil
      end
    end

    context 'non-nil user is provided' do
      let(:user) { FactoryBot.build(:user) }

      it 'queues a reindex job for the exhibit, with actual user for the log entry' do
        expect(subject).to receive(:new_reindexing_log_entry).with(user).and_return(log_entry)
        expect(Spotlight::ReindexJob).to receive(:perform_later).with(subject, log_entry)
        subject.reindex_later user
        expect(log_entry.user).to eq user
      end
    end
  end

  describe '#new_reindexing_log_entry' do
    let(:user) { FactoryBot.build(:user) }
    it 'returns a properly configured Spotlight::ReindexingLogEntry instance' do
      reindexing_log_entry = subject.send(:new_reindexing_log_entry, user)
      expect(reindexing_log_entry.exhibit).to eq subject
      expect(reindexing_log_entry.user).to eq user
      expect(reindexing_log_entry.items_reindexed_count).to eq 0
      expect(reindexing_log_entry.unstarted?).to be true
    end

    it 'does not require user the user parameter' do
      reindexing_log_entry = subject.send(:new_reindexing_log_entry)
      expect(reindexing_log_entry.exhibit).to eq subject
      expect(reindexing_log_entry.user).to be nil
      expect(reindexing_log_entry.items_reindexed_count).to eq 0
      expect(reindexing_log_entry.unstarted?).to be true
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
        expected_query_params = { fq: ["{!term f=spotlight_exhibit_slug_#{subject.slug}_bsi}true"] }
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
      let!(:exhibit_admin) { FactoryBot.create(:exhibit_admin, exhibit: subject) }
      let!(:another_exhibit_admin) { FactoryBot.create(:exhibit_admin, exhibit: subject) }

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
    let!(:reindexing_log_entries) do
      [
        FactoryBot.create(:unstarted_reindexing_log_entry, exhibit: exhibit),
        FactoryBot.create(:reindexing_log_entry, exhibit: exhibit),
        in_progress_entry,
        FactoryBot.create(:failed_reindexing_log_entry, exhibit: exhibit),
        FactoryBot.create(:unstarted_reindexing_log_entry, exhibit: exhibit)
      ]
    end

    let(:in_progress_entry) do
      FactoryBot.create(:in_progress_reindexing_log_entry, exhibit: exhibit)
    end

    it 'returns the latest log entry that is not unstarted' do
      reindex_progress = subject.reindex_progress
      expect(reindex_progress).to be_a Spotlight::ReindexProgress
      expect(reindex_progress.current_log_entry).to eq in_progress_entry
    end
  end

  it 'is expected to be versioned' do
    is_expected.to be_versioned
  end
  describe 'translatable fields' do
    let(:persisted_exhibit) { FactoryBot.create(:exhibit, title: 'Sample', subtitle: 'SubSample', description: 'Description') }
    before do
      FactoryBot.create(:translation, locale: 'fr', exhibit: persisted_exhibit, key: "#{persisted_exhibit.slug}.title", value: 'Titre français')
      FactoryBot.create(:translation, locale: 'fr', exhibit: persisted_exhibit, key: "#{persisted_exhibit.slug}.subtitle", value: 'Sous-titre français')
      FactoryBot.create(:translation, locale: 'fr', exhibit: persisted_exhibit, key: "#{persisted_exhibit.slug}.description", value: 'Description français')
      Translation.current_exhibit = persisted_exhibit
    end
    after do
      I18n.locale = 'en'
    end
    it 'has a translatable title' do
      expect(persisted_exhibit.title).to eq 'Sample'
      I18n.locale = 'fr'
      persisted_exhibit.reload
      expect(persisted_exhibit.title).to eq 'Titre français'
    end
    it 'has a translatable subtitle' do
      expect(persisted_exhibit.subtitle).to eq 'SubSample'
      I18n.locale = 'fr'
      persisted_exhibit.reload
      expect(persisted_exhibit.subtitle).to eq 'Sous-titre français'
    end

    it 'has a translatable description' do
      expect(persisted_exhibit.description).to eq 'Description'
      I18n.locale = 'fr'
      persisted_exhibit.reload
      expect(persisted_exhibit.description).to eq 'Description français'
    end
  end
end
