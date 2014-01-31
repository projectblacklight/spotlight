require 'spec_helper'

describe Spotlight::Search do

  it "should have items" do
    subject.query_params = {"f"=>{"genre_sim"=>["map"]}}
    subject.count.should == 55
  end

end
