require 'spec_helper'

describe Spotlight::HomePage, :type => :model do
  let(:home_page) { FactoryGirl.create(:home_page) }
  it {is_expected.not_to be_feature_page}
  it {is_expected.not_to be_about_page}
  it "should display the sidebar" do
    expect(home_page.display_sidebar?).to be_truthy
  end
  it "should be published" do
    expect(home_page.published).to be_truthy
  end
  describe "title" do
    it "should include default text" do
      expect(home_page.title).to eq Spotlight::HomePage.default_title_text
    end
  end
  describe "should_display_title?" do
    it "should return the display_title attribute" do
      home_page.display_title = true
      expect(home_page.should_display_title?).to be_truthy
      home_page.display_title = false
      expect(home_page.should_display_title?).to be_falsey
    end
  end
  describe 'display_sidebar?' do
    it 'should be true when the exhibit is searchable' do
      home_page.exhibit.searchable = true
      expect(home_page.display_sidebar?).to be_truthy
    end
    it 'should be false when the exhibit is not searchable' do
      home_page.exhibit.searchable = false
      expect(home_page.display_sidebar?).to be_falsey
    end
  end
  describe "content" do
    it "should include default text" do
      expect(home_page.content).to match /#{Spotlight::HomePage.default_content_text}/
    end
    it "should be parsible JSON that includes the default text" do
      json = JSON.parse(home_page.content)
      expect(json).to be_a Hash
      expect(json["data"].first["data"]["text"]).to eq Spotlight::HomePage.default_content_text
    end
  end
end
