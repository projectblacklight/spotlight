require 'spec_helper'

module Spotlight
  describe "shared/_footer" do
    let(:current_exhibit) { double(title: "Some title", subtitle: "Subtitle") }
  
    it "should display social media links" do
      view.stub(current_exhibit: current_exhibit)
      render
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-twitter[title="Twitter"]')
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-facebook[title="Facebook"]')
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-google_plus[title="Google+"]')
    end
  end
end

