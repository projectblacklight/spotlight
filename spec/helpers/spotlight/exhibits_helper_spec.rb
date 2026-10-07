# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitsHelper, type: :helper do
  let(:search) { Spotlight::ExhibitSearch.new(query) }

  describe '#highlight_exhibit_search' do
    context 'with a blank query' do
      let(:query) { '' }

      it 'returns the text unchanged' do
        expect(helper.highlight_exhibit_search('Some Title', search)).to eq 'Some Title'
      end
    end

    context 'with words from the query in a different case' do
      let(:query) { 'title some' }

      it 'marks each match' do
        expect(helper.highlight_exhibit_search('Some Exhibit Title', search)).to eq '<mark>Some</mark> Exhibit <mark>Title</mark>'
      end
    end

    context 'with a word outside ASCII in a different case' do
      let(:query) { 'été' }

      it 'marks the match' do
        expect(helper.highlight_exhibit_search('Été', search)).to eq '<mark>Été</mark>'
      end
    end

    context 'with HTML in the text' do
      let(:query) { 'title' }

      it 'escapes the text around the match' do
        expect(helper.highlight_exhibit_search('<b>Title</b>', search)).to eq '&lt;b&gt;<mark>Title</mark>&lt;/b&gt;'
      end
    end

    context 'with a word that is part of an HTML entity in the escaped text' do
      let(:query) { 'a' }

      it 'does not mark inside the entity' do
        expect(helper.highlight_exhibit_search('Arts & Crafts', search)).to eq '<mark>A</mark>rts &amp; Cr<mark>a</mark>fts'
      end
    end

    context 'with HTML in the query' do
      let(:query) { '<b>' }

      it 'escapes the match' do
        expect(helper.highlight_exhibit_search('Some <b> Title', search)).to eq 'Some <mark>&lt;b&gt;</mark> Title'
      end
    end

    context 'with regex characters in the query' do
      let(:query) { 'a.c' }

      it 'matches them as literal text' do
        expect(helper.highlight_exhibit_search('abc a.c', search)).to eq 'abc <mark>a.c</mark>'
      end
    end

    context 'with a word that contains another word from the query' do
      let(:query) { 'some something' }

      it 'marks the longer word' do
        expect(helper.highlight_exhibit_search('Something', search)).to eq '<mark>Something</mark>'
      end
    end
  end
end
