require 'spec_helper'

module Spotlight
  describe "_user_util_links" do
    before do
      view.stub(:current_user).and_return(current_user)
    end

    describe "when user is not logged in" do
      let(:current_user) { nil }
      it "renders the links" do
        render
        expect(rendered).to have_link 'Sign in'
        expect(rendered).to have_link 'Report a problem'
      end
    end

    describe "when user is logged in" do
      let(:current_user) { ::User.new }
      it "renders the links" do
        render
        expect(rendered).to have_link 'Report a problem'
        expect(rendered).to_not have_link 'Administration'
        expect(rendered).to have_link 'Sign out'
      end
    end

    describe "when user is an admin" do
      let(:current_user) { ::User.new }
      before do
        view.stub(:can?).and_return(true)
      end
      it "renders the links" do
        render
        expect(rendered).to have_link 'Report a problem'
        expect(rendered).to have_link 'Administration'
        expect(rendered).to have_link 'Sign out'
      end
    end
  end
end

