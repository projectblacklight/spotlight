require 'spec_helper'

describe Spotlight::FeaturePage, type: :model do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  describe 'default_scope' do
    let!(:page1) { FactoryGirl.create(:feature_page, weight: 5, exhibit: exhibit) }
    let!(:page2) { FactoryGirl.create(:feature_page, weight: 1, exhibit: exhibit) }
    let!(:page3) { FactoryGirl.create(:feature_page, weight: 10, exhibit: exhibit) }
    it 'orders by weight' do
      expect(described_class.all.map(&:weight)).to eq [1, 5, 10]
    end
  end

  describe 'display_sidebar?' do
    let(:parent) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    let!(:child) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit) }
    let!(:unpublished_parent) { FactoryGirl.create(:feature_page, published: false, exhibit: exhibit) }
    let!(:unpublished_child) { FactoryGirl.create(:feature_page, parent_page: unpublished_parent, published: false, exhibit: exhibit) }
    before { unpublished_parent.display_sidebar = false }
    it 'is set to true if the page has a published child' do
      expect(parent.display_sidebar?).to be_truthy
    end
    it 'is set to true on the parent of published child pages' do
      parent.display_sidebar = false
      expect(parent.display_sidebar?).to be_truthy
    end
    it 'is set to true when publishing a child page' do
      expect(unpublished_parent.display_sidebar?).to be_falsey
      unpublished_parent.published = true
      unpublished_child.published = true
      unpublished_child.save
      expect(unpublished_parent.display_sidebar?).to be_truthy
    end
  end

  describe 'weight' do
    let(:good_weight) { FactoryGirl.build(:feature_page, weight: 10, exhibit: exhibit) }
    let(:low_weight) { FactoryGirl.build(:feature_page, weight: -1, exhibit: exhibit) }
    let(:high_weight) { FactoryGirl.build(:feature_page, weight: 51, exhibit: exhibit) }
    it 'defaults to 50' do
      expect(described_class.new.weight).to eq 50
    end
    it 'validates when in the 0 to 50 range' do
      expect(good_weight).to be_valid
      expect(good_weight.weight).to eq 10
    end
    it 'raises an error when outside of the 0 to 50 range' do
      expect(low_weight).to_not be_valid
      expect(high_weight).to_not be_valid
    end
    it 'settable valid maximum' do
      stub_const('Spotlight::Page::MAX_PAGES', 51)
      expect(high_weight).to be_valid
    end
  end

  it { is_expected.to be_feature_page }
  it { is_expected.not_to be_about_page }

  describe 'relationships' do
    let(:parent) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    let!(:child1) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit) }
    let!(:child2) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit) }
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
      expect(parent.top_level_page?).to be_truthy
      expect(child1.top_level_page?).to be_falsey
      expect(child2.top_level_page?).to be_falsey
    end
  end
end
