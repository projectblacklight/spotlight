# frozen_string_literal: true

RSpec.describe Spotlight::AdminUsers::EmailComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(user:)).to_s)
  end

  let(:user) { FactoryBot.create(:user) }

  it "renders the user's email" do
    expect(rendered).to have_text(user.email)
  end

  context 'when user has a pending invite' do
    it 'renders pending badge only' do
      allow(user).to receive(:invite_pending?).and_return(true)
      expect(rendered).to have_css('.invite-pending')
      expect(rendered).to have_no_css('.site-admin')
    end
  end

  context 'when user is a site admin' do
    let(:user) { FactoryBot.create(:site_admin) }

    context 'with no pending invite' do
      it 'renders site admin badge only' do
        expect(rendered).to have_css('.site-admin')
        expect(rendered).to have_no_css('.invite-pending')
      end
    end

    context 'with a pending invite' do
      it 'renders site admin and pending badges' do
        allow(user).to receive(:invite_pending?).and_return(true)
        expect(rendered).to have_css('.site-admin')
        expect(rendered).to have_css('.invite-pending')
      end
    end
  end
end
