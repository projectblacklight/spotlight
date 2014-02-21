require 'spec_helper'

describe Spotlight::Page do

  let(:exhibit) { Spotlight::Exhibit.default }
  let!(:parent_page) {  Spotlight::FeaturePage.create! exhibit: exhibit, published: true }
  let!(:child_page) {  Spotlight::FeaturePage.create! exhibit: exhibit, published: false, parent_page: parent_page }

  describe ".at_top_level" do
    it "should scope results to only top level pages" do
      expect(Spotlight::Page.at_top_level).to_not include child_page
    end
  end

  describe ".published" do
    it "should scope results to only published pages" do
      expect(Spotlight::Page.at_top_level).to_not include child_page
    end
  end

  describe "#top_level_page?" do
    it "should check if the page is a top-level page" do
      expect(parent_page).to be_a_top_level_page
      expect(child_page).not_to be_a_top_level_page
    end
  end

  describe "#top_level_page_or_self" do  
    it "should fetch the top level page" do
      expect(child_page.top_level_page_or_self).to be parent_page
    end

    it "should be the same object if the page is a top level page" do 
      expect(parent_page.top_level_page_or_self).to be parent_page

    end
  end

  describe "title_or_default" do
    subject { FactoryGirl.build(:about_page, title: 'my title') }
    it "should return the title" do
      expect(subject.title_or_default).to eq 'my title'
    end
  end
end
