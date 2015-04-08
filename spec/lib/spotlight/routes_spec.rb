require 'spec_helper'

describe Spotlight::Routes do
  describe '#spotlight_root' do
    subject { ActionDispatch::Routing::Mapper.new(ActionDispatch::Routing::RouteSet.new) }
    it 'makes the root route' do
      expect(subject).to receive(:root).with(to: 'spotlight/default#index')
      subject.spotlight_root
    end
  end
end
