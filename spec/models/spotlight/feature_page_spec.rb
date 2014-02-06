require 'spec_helper'

describe Spotlight::FeaturePage do
  describe "default_scope" do
    let!(:page1) { FactoryGirl.create(:feature_page, weight: 5) }
    let!(:page2) { FactoryGirl.create(:feature_page, weight: 1) }
    let!(:page3) { FactoryGirl.create(:feature_page, weight: 10) }
    it "should order by weight" do
      expect(Spotlight::FeaturePage.all.map(&:weight)).to eq [1, 5, 10]
    end
  end

  describe "weight" do
    let(:good_weight) { FactoryGirl.build(:feature_page, weight: 10) }
    let(:low_weight)  { FactoryGirl.build(:feature_page, weight: -1) }
    let(:high_weight) { FactoryGirl.build(:feature_page, weight:  51) }
    it "should default to 0" do
      expect(Spotlight::FeaturePage.new.weight).to eq 0
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
    let(:parent)  { FactoryGirl.create(:feature_page) }
    let!(:child1) { FactoryGirl.create(:feature_page, :parent_page => parent ) }
    let!(:child2) { FactoryGirl.create(:feature_page, :parent_page => parent ) }
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
