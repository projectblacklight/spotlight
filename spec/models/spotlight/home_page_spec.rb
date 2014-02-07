require 'spec_helper'

describe Spotlight::HomePage do
  let(:home_page) { FactoryGirl.create(:home_page) }
  it {should_not be_feature_page}
  it {should_not be_about_page}
  it "should display the sidebar" do
    expect(home_page.display_sidebar).to be_true
  end
  it "should be published" do
    expect(home_page.published).to be_true
  end
end
