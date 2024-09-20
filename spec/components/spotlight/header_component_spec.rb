# frozen_string_literal: true

RSpec.describe Spotlight::HeaderComponent, type: :component do
  before do
    with_controller_class(CatalogController) do
      allow(controller).to receive_messages(current_user: current_user, search_action_url: '/search')
      render
    end
  end

  context 'with no slots' do
    let(:render) { render_inline(described_class.new(blacklight_config: CatalogController.blacklight_config)) }
    let(:current_user) { Spotlight::Engine.user_class.new }
    let(:exhibit) { FactoryBot.create(:exhibit) }
    #let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

    it 'draws the topbar' do
      expect(page).to have_css 'nav.topbar'
      expect(page).to have_link 'Blacklight', href: '/'
      expect(page).to have_selector '#user-util-collapse'
    end
  end
end
