# frozen_string_literal: true

RSpec.describe Spotlight::FeaturePage, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'default_scope' do
    let!(:page1) { FactoryBot.create(:feature_page, weight: 5, exhibit:) }
    let!(:page2) { FactoryBot.create(:feature_page, weight: 1, exhibit:) }
    let!(:page3) { FactoryBot.create(:feature_page, weight: 10, exhibit:) }

    it 'orders by weight' do
      expect(described_class.all.map(&:weight)).to eq [1, 5, 10]
    end
  end

  describe 'display_sidebar?' do
    let(:parent) { FactoryBot.create(:feature_page, exhibit:) }
    let!(:child) { FactoryBot.create(:feature_page, parent_page: parent, exhibit:) }
    let!(:unpublished_parent) { FactoryBot.create(:feature_page, published: false, exhibit:) }
    let!(:unpublished_child) { FactoryBot.create(:feature_page, parent_page: unpublished_parent, published: false, exhibit:) }

    before { unpublished_parent.display_sidebar = false }

    it 'is set to true if the page has a published child' do
      expect(parent).to be_display_sidebar
    end

    it 'is set to true on the parent of published child pages' do
      parent.display_sidebar = false
      expect(parent).to be_display_sidebar
    end

    it 'is set to true when publishing a child page' do
      expect(unpublished_parent).not_to be_display_sidebar
      unpublished_parent.published = true
      unpublished_child.published = true
      unpublished_child.save
      expect(unpublished_parent).to be_display_sidebar
    end
  end

  describe 'weight' do
    let(:good_weight) { FactoryBot.build(:feature_page, weight: 10, exhibit:) }
    let(:low_weight) { FactoryBot.build(:feature_page, weight: -1, exhibit:) }
    let(:high_weight) { FactoryBot.build(:feature_page, weight: 1200, exhibit:) }

    it 'defaults to 1000' do
      expect(described_class.new.weight).to eq 1000
    end

    it 'validates when in the 0 to 50 range' do
      expect(good_weight).to be_valid
      expect(good_weight.weight).to eq 10
    end

    it 'raises an error when outside of the 0 to 50 range' do
      expect(low_weight).not_to be_valid
      expect(high_weight).not_to be_valid
    end
  end

  it { is_expected.to be_feature_page }
  it { is_expected.not_to be_about_page }

  describe 'relationships' do
    let(:parent) { FactoryBot.create(:feature_page, exhibit:) }
    let!(:child1) { FactoryBot.create(:feature_page, parent_page: parent, exhibit:) }
    let!(:child2) { FactoryBot.create(:feature_page, parent_page: parent, exhibit:) }

    it 'child pages should have a parent_page' do
      [child1, child2].each do |child|
        expect(child.parent_page).to eq parent
      end
    end

    it 'parent pages should have child_pages' do
      expect(parent.child_pages.length).to eq 2
      expect(parent.child_pages.map(&:id)).to eq [child1.id, child2.id]
    end

    it 'defines top_level_page? properly' do
      expect(parent).to be_top_level_page
      expect(child1).not_to be_top_level_page
      expect(child2).not_to be_top_level_page
    end

    context 'with a missing parent translation' do
      let(:child1_es) { child1.clone_for_locale('es') }

      before { child1_es.save }

      it 'parent pages should have child_pages matching the parent locale' do
        expect(parent.child_pages.length).to eq 2
        expect(parent.child_pages.map(&:id)).to eq [child1.id, child2.id]
      end
    end

    context 'with a parent translation' do
      let(:parent_es) { parent.clone_for_locale('es') }
      let(:child1_es) { child1.clone_for_locale('es') }

      before do
        parent_es.save
        child1_es.save
      end

      it 'parent pages should have child_pages matching the parent locale' do
        expect(parent.child_pages.length).to eq 2
        expect(parent.child_pages.map(&:id)).to eq [child1.id, child2.id]
        expect(parent_es.child_pages.length).to eq 1
        expect(parent_es.child_pages.map(&:id)).to eq [child1_es.id]
      end
    end
  end
end
