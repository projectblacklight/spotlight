require 'spec_helper'

describe Spotlight::Search do

  before do
    subject.query_params = {"f"=>{"genre_sim"=>["map"]}}
    subject.exhibit = FactoryGirl.create(:exhibit)
  end

  it { should be_a Spotlight::Catalog::AccessControlsEnforcement }

  it "should have a default feature image" do
    subject.stub(images: [['title', 'image_url'], ['title1', 'image2']])
    subject.save
    expect(subject.featured_image).to eq 'image_url'
  end

  it "should #default_featured_iamge should not thrown an error when no images are present" do
    subject.stub(images: nil)
    expect(subject.default_featured_image).to be_nil
  end

  it "should have items" do
    expect(subject.count).to eq 55
  end

  it "should have images" do
    subject.images.size.should == 55
    expect(subject.images.map(&:last)).to include "https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb", "https://stacks.stanford.edu/image/jp266yb7109/jp266yb7109_05_0001_thumb"
  end

  describe "default_scope" do
    let!(:page1) { FactoryGirl.create(:search, weight: 5, on_landing_page: true) }
    let!(:page2) { FactoryGirl.create(:search, weight: 1, on_landing_page: true) }
    let!(:page3) { FactoryGirl.create(:search, weight: 10, on_landing_page: true) }
    it "should order by weight" do
      expect(Spotlight::Search.published.map(&:weight)).to eq [1, 5, 10]
    end
  end
end
