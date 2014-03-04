require 'spec_helper'

describe ActionDispatch::Routing::Mapper do
  describe "#spotlight_root" do
    subject { ActionDispatch::Routing::Mapper.new(ActionDispatch::Routing::RouteSet.new) }
    it "should make the root route" do
      subject.should_receive(:root).with(to: "spotlight/home_pages#show", defaults: {exhibit_id: 'default-exhibit'})
      subject.spotlight_root
    end
  end
end
