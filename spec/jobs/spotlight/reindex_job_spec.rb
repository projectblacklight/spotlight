require 'spec_helper'

describe Spotlight::ReindexJob do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:resource) { FactoryGirl.create(:resource) }

  before do
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
  end

  context 'with an exhibit' do
    subject { described_class.new(exhibit) }

    before do
      exhibit.resources << resource
      exhibit.save
    end
    it 'attempts to reindex every resource in the exhibit' do
      # ActiveJob will reload the collection, so we go through a little trouble:
      expect_any_instance_of(Spotlight::Resource).to receive(:reindex) do |thingy|
        expect(exhibit.resources).to include thingy
      end

      subject.perform_now
    end
  end

  context 'with a resource' do
    subject { described_class.new(resource) }

    it 'attempts to reindex every resource in the exhibit' do
      expect(resource).to receive(:reindex)
      subject.perform_now
    end
  end
end
