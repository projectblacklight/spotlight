require 'spec_helper'

describe Spotlight::FeaturePage do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  describe "default_scope" do
    let!(:page1) { FactoryGirl.create(:feature_page, weight: 5, exhibit: exhibit) }
    let!(:page2) { FactoryGirl.create(:feature_page, weight: 1, exhibit: exhibit) }
    let!(:page3) { FactoryGirl.create(:feature_page, weight: 10, exhibit: exhibit) }
    it "should order by weight" do
      expect(Spotlight::FeaturePage.all.map(&:weight)).to eq [1, 5, 10]
    end
  end

  describe "display_sidebar" do
    let(:parent)  { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    let(:child) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit ) }
    let!(:unpublished_parent)  { FactoryGirl.create(:feature_page, published: false, exhibit: exhibit) }
    let!(:unpublished_child) { FactoryGirl.create(:feature_page, parent_page: unpublished_parent, published: false, exhibit: exhibit ) }
    it "should be set to true on the parent of published child pages" do
      expect(parent.display_sidebar).to be_false
      child.save
      expect(parent.display_sidebar).to be_true
    end
    it "should be set to true when publishing a child page" do
      expect(unpublished_parent.display_sidebar).to be_false
      unpublished_parent.published = true
      unpublished_child.published = true
      unpublished_child.save
      expect(unpublished_parent.display_sidebar).to be_true
    end
    it "should not change the display_sidebar setting when the child page is not published" do
      unpublished_child.save
      expect(unpublished_parent.display_sidebar).to be_false
    end
    it "should not change the setting when the parent page is not published" do
      expect(unpublished_parent.display_sidebar).to be_false
      unpublished_child.published = true
      unpublished_child.save
      expect(unpublished_parent.display_sidebar).to be_false
    end
  end

  describe "weight" do
    let(:good_weight) { FactoryGirl.build(:feature_page, weight: 10, exhibit: exhibit) }
    let(:low_weight)  { FactoryGirl.build(:feature_page, weight: -1, exhibit: exhibit) }
    let(:high_weight) { FactoryGirl.build(:feature_page, weight:  51, exhibit: exhibit) }
    it "should default to 50" do
      expect(Spotlight::FeaturePage.new.weight).to eq 50
    end
    it "should validate when in the 0 to 50 range" do
      expect(good_weight).to be_valid
      expect(good_weight.weight).to eq 10
    end
    it "should raise an error when outside of the 0 to 50 range" do
      expect(low_weight ).to_not be_valid
      expect(high_weight).to_not be_valid
    end
    it "settable valid maximum" do
      stub_const("Spotlight::Page::MAX_PAGES", 51)
      expect(high_weight).to be_valid
    end
  end

  it {should be_feature_page}
  it {should_not be_about_page}

  describe "relationships" do
    let(:parent)  { FactoryGirl.create(:feature_page, exhibit: exhibit) }
    let!(:child1) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit ) }
    let!(:child2) { FactoryGirl.create(:feature_page, parent_page: parent, exhibit: exhibit ) }
    it "child pages should have a parent_page" do
      [child1, child2].each do |child|
         expect(child.parent_page).to eq parent
      end
    end
    it "parent pages should have child_pages" do
      expect(parent.child_pages.length).to eq 2
      expect(parent.child_pages.map(&:id)).to eq [child1.id, child2.id]
    end
    it "should define top_level_page? properly" do
      expect(parent.top_level_page?).to be_true
      expect(child1.top_level_page?).to be_false
      expect(child2.top_level_page?).to be_false
    end
  end
end
