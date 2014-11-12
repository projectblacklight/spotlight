require 'spec_helper'

describe ActionDispatch::Routing::Mapper do
  describe "#spotlight_root" do
    subject { ActionDispatch::Routing::Mapper.new(ActionDispatch::Routing::RouteSet.new) }
    it "should make the root route" do
      expect(subject).to receive(:root).with(to: "spotlight/default#index")
      subject.spotlight_root
    end
  end
end
