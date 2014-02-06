require 'spec_helper'

describe "spotlight/searches/index.html.erb" do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }

  before do
    view.stub(update_all_exhibit_searches_path: "/")
    assign(:exhibit, exhibit)
  end

  describe "Without searches" do
    it "should disable the update button" do
      assign(:searches, [])
      render
      expect(rendered).to have_selector("input[type=submit][value='Save changes'][disabled]")
    end
  end
end
