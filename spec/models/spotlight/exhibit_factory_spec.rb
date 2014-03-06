require 'spec_helper'

describe Spotlight::ExhibitFactory do
  let(:exhibit) { FactoryGirl.build(:exhibit) }
  describe "that is saved" do
    before { Spotlight::ExhibitFactory.create(exhibit) }

    it "should have a configuration" do
      expect(exhibit.blacklight_configuration).to be_kind_of Spotlight::BlacklightConfiguration
    end

    it "should have an unpublished search" do
      expect(exhibit.searches).to have(1).search
      expect(exhibit.searches.published).to be_empty
      expect(exhibit.searches.first.query_params).to be_empty
    end

    describe "import" do
      let (:values) { double }
      it "should remove the default browse category" do
        expect { Spotlight::ExhibitFactory.import(exhibit, {}) }.to change {exhibit.searches.count}.by(-1)
        expect(exhibit.searches.map { |x| x.title }).not_to include "Browse All Exhibit Items"
      end

      it "should import nested attributes from the hash" do
        exhibit.should_receive(:update).with(values)
        Spotlight::ExhibitFactory.import(exhibit, values)
      end
    end
  end
end
