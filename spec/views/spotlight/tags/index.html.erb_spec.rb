require 'spec_helper'

describe "spotlight/tags/index.html.erb" do
  let(:exhibit) { Spotlight::Exhibit.default }
  let(:tag1) { FactoryGirl.create(:tag, name: "TAG1") }
  let(:tag2) { FactoryGirl.create(:tag, name: "TAG2") }
  before do
    assign(:tags, [tag1, tag2])
    assign(:exhibit, exhibit)
    view.stub(exhibit_tag_path: "/tags")
    view.stub(:current_exhibit).and_return(exhibit)
    view.send(:extend, Spotlight::CrudLinkHelpers)
  end
  describe "Tags" do
    it "should be displayed" do
      render
      [tag1.name, tag2.name].each do |name|
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
