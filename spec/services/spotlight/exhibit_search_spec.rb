# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitSearch do
  subject(:search) { described_class.new(query) }

  let(:maps) { FactoryBot.create(:skinny_exhibit, title: 'Early Maps', subtitle: 'Of the Americas', description: '<p>Charts &amp; globes</p>') }
  let(:islands) { FactoryBot.create(:skinny_exhibit, title: 'California as an Island', subtitle: nil, description: 'A cartographic myth') }
  let(:exhibits) { [maps, islands] }

  describe '#terms' do
    let(:query) { "  maps   Maps\tamericas " }

    it 'splits the squished query on whitespace, ignoring case-insensitive duplicates' do
      expect(search.terms).to eq %w[maps americas]
      expect(search.query).to eq 'maps Maps americas'
    end
  end

  describe '#filter' do
    context 'with a blank query' do
      let(:query) { ' ' }

      it 'returns the exhibits unchanged' do
        expect(search).not_to be_active
        expect(search.filter(exhibits)).to eq exhibits
      end
    end

    context 'with a title match in a different case' do
      let(:query) { 'MAPS' }

      it { expect(search.filter(exhibits)).to eq [maps] }
    end

    context 'with terms spread across fields, in any order' do
      let(:query) { 'americas early' }

      it { expect(search.filter(exhibits)).to eq [maps] }
    end

    context 'when only some terms match' do
      let(:query) { 'maps island' }

      it { expect(search.filter(exhibits)).to be_empty }
    end

    context 'with a match in the description text' do
      let(:query) { 'charts & globes' }

      it 'matches the decoded text, not the HTML' do
        expect(search.filter(exhibits)).to eq [maps]
        expect(described_class.new('amp').filter(exhibits)).to be_empty
        expect(described_class.new('<p>').filter(exhibits)).to be_empty
      end
    end
  end

  describe '#paginate' do
    before do
      exhibits
      allow(Spotlight::Exhibit).to receive(:default_per_page).and_return(1)
    end

    context 'with an active search' do
      let(:query) { 'a' }

      it 'paginates the matching exhibits at the exhibit page size' do
        page = search.paginate(Spotlight::Exhibit.order(:id), page: 2)

        expect(page.total_count).to eq 2
        expect(page.to_a).to eq [islands]
      end
    end

    context 'without an active search' do
      let(:query) { nil }

      it 'paginates the relation' do
        relation = Spotlight::Exhibit.order(:id)

        expect(search.paginate(relation, page: 1)).to be_a ActiveRecord::Relation
      end
    end
  end
end
