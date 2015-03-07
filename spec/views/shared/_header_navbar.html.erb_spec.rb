require 'spec_helper'

module Spotlight
  describe "shared/_header_navbar", :type => :view do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let(:masthead) { 'exhibit-masthead' }
    let(:navbar) { 'exhibit-navbar' }
    let(:breadcrumbs) { 'exhibit-breadcrumbs' }
    before do
      stub_template '_user_util_links.html.erb' => 'links'
      stub_template 'shared/_exhibit_masthead.html.erb' => masthead
      stub_template 'shared/_exhibit_navbar.html.erb' => navbar
      stub_template 'shared/_breadcrumbs.html.erb' => breadcrumbs
      allow(view).to receive_messages(current_search_masthead?: nil)
      allow(view).to receive_messages(current_exhibit: current_exhibit)
    end
    it 'should render the masthead above the navbar' do
      render
      expect(rendered.index(masthead)).to be < rendered.index(navbar)
    end
    it 'should render the navbar above the search masthead' do
      allow(view).to receive_messages(current_search_masthead?: true)
      render
      expect(rendered.index(navbar)).to be < rendered.index(masthead)
    end
    it 'should render the breadcrumbs' do
      render
      expect(rendered).to have_content(breadcrumbs)
    end
    it 'should not render breadcrumbs when there is a search masthead' do
      allow(view).to receive_messages(current_search_masthead?: true)
      render
      expect(rendered).to_not have_content(breadcrumbs)
    end
  end
end
