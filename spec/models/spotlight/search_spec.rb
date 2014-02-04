require 'spec_helper'

describe Spotlight::Search do

  before do
    subject.query_params = {"f"=>{"genre_sim"=>["map"]}}
  end

  it "should have items" do
    expect(subject.count).to eq 55
  end

  it "should have images" do
    subject.images.size.should == 55
    expect(subject.images).to include "https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb", "https://stacks.stanford.edu/image/jp266yb7109/jp266yb7109_05_0001_thumb"
  end

end
