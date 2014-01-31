require 'spec_helper'

module Spotlight
  describe Page do
    describe "default_scope" do
      let!(:page1) { Spotlight::Page.create(:title => "Page2", :weight => 5 ) }
      let!(:page2) { Spotlight::Page.create(:title => "Page1", :weight => 1 ) }
      let!(:page3) { Spotlight::Page.create(:title => "Page3", :weight => 10) }
      it "should order by weight" do
        expect(Spotlight::Page.all.map(&:weight)).to eq [1, 5, 10]
      end
    end
    describe "weight" do
      let(:page1)       { Spotlight::Page.create(:title => "Page1") }
      let(:good_weight) { Spotlight::Page.create(:title => "Page1", :weight => 10) }
      let(:low_weight)  { Spotlight::Page.create(:title => "Page1", :weight => -1) }
      let(:high_weight) { Spotlight::Page.create(:title => "Page1", :weight =>  51) }
      it "should default to 0" do
        expect(page1.weight).to eq 0
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
    describe "relationships" do
      let(:parent)  { Spotlight::Page.create(:title => "Parent Page") }
      let!(:child1) { Spotlight::Page.create(:title => "Child Page1", :parent_page => parent ) }
      let!(:child2) { Spotlight::Page.create(:title => "Child Page2", :parent_page => parent ) }
      it "child pages should have a parent_page" do
        [child1, child2].each do |child|
           expect(child.parent_page).to eq parent
        end
      end
      it "parent pages should have child_pages" do
        expect(parent.child_pages.length).to eq 2
        expect(parent.child_pages.map(&:id)).to eq [child1.id, child2.id]
      end
    end
  end
end
