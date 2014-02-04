require 'spec_helper'

module Spotlight
  describe AboutPage do
    describe "feature_page?" do
      let(:page) { FactoryGirl.create(:about_page) }
      it "should return false" do
        expect(page.feature_page?).to be_false
      end
    end
  end
end
