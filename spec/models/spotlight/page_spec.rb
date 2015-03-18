require 'spec_helper'

describe Spotlight::Page, :type => :model do

  let(:exhibit) { FactoryGirl.create(:exhibit) }
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
  describe ".display_sidebar" do
    it "should be set to true by default" do
      expect(parent_page.display_sidebar?).to be_truthy
    end
  end
  describe "should_display_title?" do
    let(:page) { FactoryGirl.create(:feature_page) }
    it "should return if the title is present or not" do
      expect(page.title).not_to be_blank
      expect(page.should_display_title?).to be_truthy
      page.title = ""
      expect(page.should_display_title?).to be_falsey
    end
  end

  describe "#content=" do
    let(:page) { FactoryGirl.create(:feature_page) }

    it "should work with a serialized JSON array" do
      page.content = [].to_json
      expect(page.content).to be_a_kind_of SirTrevorRails::BlockArray
    end
    it "should work with an array" do
      page.content = []
      expect(page.content).to be_a_kind_of SirTrevorRails::BlockArray
    end
  end

  describe "#has_content?" do
    let(:page) { FactoryGirl.create(:feature_page) }

    it "should not have content when the page is empty" do
      page.content = []
      expect(page).not_to have_content
    end

    it "should have content when the page has a widget" do
      page.content = [{type: 'rule'}]
      expect(page).to have_content
    end

  end
end
