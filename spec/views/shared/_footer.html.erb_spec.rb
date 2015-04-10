require 'spec_helper'

module Spotlight
  describe 'shared/_footer', type: :view do
    let(:current_exhibit) { double(title: 'Some title', subtitle: 'Subtitle') }

    before do
      allow(view).to receive_messages(current_exhibit: current_exhibit)
    end

    it 'includes analytics reporting' do
      stub_template 'shared/_analytics.html.erb' => 'analytics'
      render
      expect(rendered).to have_content 'analytics'
    end

    it 'displays social media links' do
      render
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-twitter[title="Twitter"]')
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-facebook[title="Facebook"]')
      expect(rendered).to have_selector('footer .social-share-button a.social-share-button-google_plus[title="Google+"]')
    end
  end
end
