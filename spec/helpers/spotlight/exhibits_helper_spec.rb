# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitsHelper, type: :helper do
  let(:search) { Spotlight::ExhibitSearch.new(query) }

  describe '#highlight_exhibit_search_terms' do
    let(:query) { 'map world' }

    it 'wraps each term in a mark, ignoring case' do
      expect(helper.highlight_exhibit_search_terms('Mapping the New World', search)).to eq '<mark>Map</mark>ping the New <mark>World</mark>'
    end

    it 'escapes the rest of the text' do
      expect(helper.highlight_exhibit_search_terms('<b>maps</b> & more', search)).to eq '&lt;b&gt;<mark>map</mark>s&lt;/b&gt; &amp; more'
    end

    it 'prefers the longest overlapping term' do
      search = Spotlight::ExhibitSearch.new('map maps')

      expect(helper.highlight_exhibit_search_terms('maps', search)).to eq '<mark>maps</mark>'
    end

    it 'treats terms literally' do
      search = Spotlight::ExhibitSearch.new('a.c')

      expect(helper.highlight_exhibit_search_terms('abc a.c', search)).to eq 'abc <mark>a.c</mark>'
    end

    context 'without an active search' do
      let(:query) { '' }

      it 'returns the text unchanged' do
        expect(helper.highlight_exhibit_search_terms('Maps', search)).to eq 'Maps'
      end
    end
  end

  describe '#exhibit_search_matching_tag_names' do
    let(:query) { 'maps' }

    before do
      FactoryBot.create(:exhibit, title: 'Early Maps', tag_list: %w[a b])
      FactoryBot.create(:exhibit, title: 'Letters', tag_list: %w[c])
    end

    it 'lists the tags of the matching exhibits' do
      expect(helper.exhibit_search_matching_tag_names(Spotlight::Exhibit.all, search)).to eq Set['a', 'b']
    end

    context 'without an active search' do
      let(:query) { '' }

      it 'is nil' do
        expect(helper.exhibit_search_matching_tag_names(Spotlight::Exhibit.all, search)).to be_nil
      end
    end
  end

  describe '#exhibit_search_status' do
    let(:query) { 'maps' }

    it 'counts the matches when the page has no tabs' do
      expect(helper.exhibit_search_status(1, search:)).to eq '1 exhibit matches “maps”.'
      expect(helper.exhibit_search_status(0, search:)).to eq 'No exhibits match “maps”.'
    end

    it 'counts the matches in the given tab' do
      expect(helper.exhibit_search_status(3, tab: :published, search:)).to eq '3 published exhibits match “maps”.'
      expect(helper.exhibit_search_status(1, tab: :unpublished, search:)).to eq '1 unpublished exhibit matches “maps”.'
      expect(helper.exhibit_search_status(0, tab: :user, search:)).to eq 'None of your exhibits match “maps”.'
      expect(helper.exhibit_search_status(1, tab: :user, search:)).to eq '1 of your exhibits matches “maps”.'
      expect(helper.exhibit_search_status(2, tab: :user, search:)).to eq '2 of your exhibits match “maps”.'
    end

    context 'with a blank query' do
      let(:query) { '' }

      it 'reports that all exhibits are shown' do
        helper.params[:q] = ''

        expect(helper.exhibit_search_status(3, tab: :published, search:)).to eq 'Showing all exhibits.'
      end

      it 'is empty when no search was made' do
        expect(helper.exhibit_search_status(3, search:)).to be_nil
      end
    end
  end
end
