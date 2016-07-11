describe Spotlight::ApplicationHelper, type: :helper do
  describe '#application_name' do
    let(:site) { Spotlight::Site.instance }
    before do
      allow(helper).to receive(:current_site).and_return(site)
    end

    it 'includes the exhibit' do
      allow(helper).to receive_messages(current_exhibit: double(title: 'My Exhibit'))
      expect(helper.application_name).to eq 'My Exhibit - Blacklight'
    end

    it "is just the application name if there isn't an exhibit" do
      allow(helper).to receive_messages(current_exhibit: nil)
      expect(helper.application_name).to eq 'Blacklight'
    end

    context 'with a configured site title' do
      before do
        site.title = 'Some Title'
        allow(helper).to receive_messages(current_exhibit: nil)
      end

      it 'uses the configured name' do
        expect(helper.application_name).to eq 'Some Title'
      end
    end
  end

  describe '#url_to_tag_facet' do
    before do
      allow(helper).to receive_messages(current_exhibit: FactoryGirl.create(:exhibit))
      allow(helper).to receive_messages(blacklight_config: Blacklight::Configuration.new)

      # controller provided helper.
      allow(helper).to receive(:search_action_url) do |*args|
        spotlight.search_exhibit_catalog_path(helper.current_exhibit, *args)
      end
    end

    it 'is a url for a search with the given tag facet' do
      allow(SolrDocument).to receive_messages(solr_field_for_tagger: :exhibit_tags)
      expected = spotlight.search_exhibit_catalog_path(exhibit_id: helper.current_exhibit, f: { exhibit_tags: ['tag_value'] })
      expect(helper.url_to_tag_facet('tag_value')).to eq expected
    end
  end

  describe 'search block helpers' do
    describe 'selected_search_block_views' do
      let(:block) do
        SirTrevorRails::Block.new({ type: 'xyz', data: { a: 'on', b: 'off', c: false, d: 'on' } }, 'parent')
      end

      it "returns keys with a value of 'on'" do
        expect(helper.selected_search_block_views(block)).to eq %w(a d)
      end
    end
    describe 'blacklight_view_config_for_search_block' do
      let(:sir_trevor_block) do
        SirTrevorRails::Block.new({ type: 'xyz', data: { view: %w(list gallery) } }, 'parent')
      end

      let(:config) do
        Blacklight::Configuration.new do |config|
          config.view.list = {}
          config.view.gallery = {}
          config.view.slideshow = {}
        end
      end
      before do
        allow(helper).to receive_messages(blacklight_config: config)
      end
      it 'returns a blacklight configuration object that has reduced the views to those that are configured in the block' do
        new_config = helper.blacklight_view_config_for_search_block(sir_trevor_block)
        expect(new_config.keys).to eq [:list, :gallery]
      end
    end
  end

  describe 'render_document_class' do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let(:document) { SolrDocument.new(some_field: 'Some data') }
    before do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      allow(helper).to receive_messages(blacklight_config: Blacklight::Configuration.new do |config|
        config.index.display_type_field = :some_field
      end)
    end
    it 'returns blacklight-private when the document is private' do
      allow(document).to receive(:private?).with(current_exhibit).and_return(true)
      expect(helper.render_document_class(document)).to include 'blacklight-private'
    end
    it 'prefixs "blacklight-" to the configured type' do
      expect(helper.render_document_class(document)).to include 'blacklight-some-data'
    end
  end

  describe '#add_exhibit_twitter_card_content' do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    before do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      current_exhibit.subtitle = 'xyz'
      current_exhibit.description = 'abc'
      TopHat.current['twitter_card'] = nil
    end

    it 'generates a twitter card for the exhibit' do
      allow(helper).to receive(:exhibit_root_url).and_return('some/url')
      allow(current_exhibit).to receive(:thumbnail).and_return(double)
      allow(current_exhibit).to receive_message_chain(:thumbnail, :image, :thumb, url: '/image')

      helper.add_exhibit_twitter_card_content

      card = helper.twitter_card
      expect(card).to have_css "meta[name='twitter:card'][value='summary']", visible: false
      expect(card).to have_css "meta[name='twitter:url'][value='some/url']", visible: false
      expect(card).to have_css "meta[name='twitter:title'][value='#{current_exhibit.title}']", visible: false
      expect(card).to have_css "meta[name='twitter:description'][value='#{current_exhibit.subtitle}']", visible: false
      expect(card).to have_css "meta[name='twitter:image'][value='http://test.host/image']", visible: false
    end
  end

  describe '#carrierwave_url' do
    it 'turns a application-relative URI into a path' do
      upload = double(url: '/x/y/z')
      expect(helper.carrierwave_url(upload)).to eq 'http://test.host/x/y/z'
    end

    it 'passes a full URI through' do
      upload = double(url: 'http://some.host/x/y/z')
      expect(helper.carrierwave_url(upload)).to eq 'http://some.host/x/y/z'
    end
  end

  describe '#uploaded_field_label' do
    let(:field) { OpenStruct.new field_name: 'x' }
    let(:blacklight_config) { Blacklight::Configuration.new }

    before do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end

    it 'uses the configuration-provided label' do
      field.label = 'label x'
      expect(helper.uploaded_field_label(field)).to eq 'label x'
    end

    it 'pulls the label from the solr field' do
      blacklight_config.add_index_field 'x', label: 'solr x'
      expect(helper.uploaded_field_label(field)).to eq 'solr x'
    end
  end

  describe '#available_view_fields' do
    let(:blacklight_config) { Blacklight::Configuration.new }

    before do
      allow(helper).to receive_message_chain(:current_exhibit, :blacklight_configuration, default_blacklight_config: blacklight_config)
    end

    it 'excludes view fields that are never visible (e.g. atom, rss)' do
      blacklight_config.view.a.if = true
      blacklight_config.view.b.if = false

      expect(helper.available_view_fields).to include :a
      expect(helper.available_view_fields).to_not include :b
    end
  end

  describe '#block_document_index_view_type' do
    let(:blacklight_config) { Blacklight::Configuration.new }
    let(:block) { double(view: %w(b c)) }
    let(:block_with_bad_or_missing_data) { double(view: []) }

    before do
      # clean out the default views
      blacklight_config.view.reject! { |_| true }

      blacklight_config.view.a
      blacklight_config.view.b
      blacklight_config.view.c
      allow(helper).to receive(:blacklight_config).and_return(blacklight_config)
    end

    it 'selects the users chosen view' do
      allow(helper).to receive(:document_index_view_type).and_return(:c)
      expect(helper.block_document_index_view_type(block)).to eq :c
    end

    it 'defaults to the first available blacklight views' do
      allow(helper).to receive(:document_index_view_type).and_return(:a)
      expect(helper.block_document_index_view_type(block)).to eq :b
    end

    it 'falls back to the original default view' do
      allow(helper).to receive(:document_index_view_type).and_return(:value_not_present)
      expect(helper.block_document_index_view_type(block_with_bad_or_missing_data)).to eq :a
    end
  end
end
