require 'spec_helper'

describe "spotlight/tags/index.html.erb" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:tag1) { FactoryGirl.create(:tagging, tagger: exhibit) }
  let!(:tag2) { FactoryGirl.create(:tagging, tagger: exhibit) }
  before do
    assign(:exhibit, exhibit)
    assign(:tags, exhibit.owned_tags)
    view.stub(exhibit_tag_path: "/tags")
    view.stub(:current_exhibit).and_return(exhibit)
    view.stub(:url_to_tag_facet) { |*args| args.first }
  end
  describe "Tags" do
    it "should be displayed" do
      render
      [tag1.tag.name, tag2.tag.name].each do |name|
        expect(rendered).to have_css("td", text: name)
      end
    end
  end
  describe "Total tags" do
    it "should be displayed" do
      render
      expect(rendered).to have_css("span.label.label-default", text: 2)
    end
  end
end
