require 'spec_helper'

describe Spotlight::AboutPage do
  let(:page) { Spotlight::AboutPage.create! exhibit: FactoryGirl.create(:exhibit)  }
  it {should_not be_feature_page}
  it {should be_about_page}
  it "should display the sidebar" do
    expect(page.display_sidebar?).to be_true
  end
  it "should force the sidebar to display (we do not provide an interface for setting this to false)" do
    expect(page.display_sidebar?).to be_true
    page.display_sidebar = false
    page.save
    expect(page.display_sidebar?).to be_true
  end
end
