require 'spec_helper'

describe Spotlight::AboutPage do
  it {should_not be_feature_page}
  it {should be_about_page}
  it "should display the sidebar" do
    page = Spotlight::AboutPage.create! exhibit: Spotlight::ExhibitFactory.default

    expect(page.display_sidebar).to be_true
  end
end
