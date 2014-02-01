require "spec_helper"

describe Spotlight::ApplicationHelper do
  describe "spotlight_pages_path_for" do
    let(:exhibit) { stub_model(Spotlight::Exhibit) }
    it "pass the model name when given" do
      expect(helper.new_spotlight_page_path_for(exhibit, "about_page")).to match /spotlight\/exhibits\/\d+\/about\/new/
      expect(helper.new_spotlight_page_path_for(exhibit, "feature_page")).to match /spotlight\/exhibits\/\d+\/feature\/new/
    end
  end
end
