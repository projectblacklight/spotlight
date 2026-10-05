# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/index', type: :view do
  let(:exhibits) { Spotlight::Exhibit.none }
  let(:published_exhibits) { exhibits.published.listed.page(1) }

  let(:ability) { Ability.new(user) }
  let(:user) { Spotlight::Engine.user_class.new }

  before do
    assign(:exhibits, exhibits)
    assign(:published_exhibits, published_exhibits)
    allow(view).to receive_messages(exhibits_path: '/', exhibit_path: '/', current_user: user, current_ability: ability)
  end

  context 'with published exhibits' do
    let!(:exhibit_a) { FactoryBot.create(:exhibit, published: true) }
    let!(:exhibit_b) { FactoryBot.create(:exhibit, published: true) }
    let!(:exhibit_c) { FactoryBot.create(:exhibit, published: false) }
    let!(:exhibit_d) { FactoryBot.create(:exhibit, published: true, listed: false) }

    let(:exhibits) { Spotlight::Exhibit.all }

    it 'renders the published exhibits' do
      render

      expect(rendered).to have_css('.exhibit-card', count: 2)
      expect(rendered).to have_text exhibit_a.title
      expect(rendered).to have_text exhibit_b.title
      expect(rendered).to have_no_text exhibit_c.title
      expect(rendered).to have_no_text exhibit_d.title

      expect(rendered).not_to include 'Private exhibits'
    end

    it 'does not include the tab bar' do
      render

      expect(rendered).to have_no_selector '.nav-tabs'
    end

    it 'does not include tags controls' do
      render

      expect(rendered).to have_no_selector '.tags'
    end

    it 'does not include pagination controls' do
      render

      expect(rendered).to have_no_selector '.pager'
    end

    context 'with tagged exhibits' do
      before do
        exhibit_a.tag_list = ['a']
        exhibit_b.tag_list = ['a']
        exhibit_c.tag_list = ['b']

        exhibit_a.save
        exhibit_b.save
        exhibit_c.save
      end

      it 'filters by tags' do
        render

        expect(rendered).to have_link 'All'
        expect(rendered).to have_link 'a'
        expect(rendered).to have_link 'b'
      end
    end

    context 'with paginated exhibits' do
      let(:published_exhibits) { exhibits.published.listed.page(1).per(1) }

      it 'renders pagination controls' do
        render

        expect(rendered).to have_css '.pagination'
        expect(rendered).to have_link 'Next', href: '/?page=2'
      end
    end

    context 'with an exhibit admin' do
      let(:user) { FactoryBot.create(:exhibit_admin) }

      it 'includes a tab with the exhibits curated by the user' do
        render

        expect(rendered).to have_css '.nav-tabs'
        expect(rendered).to have_link 'Your exhibits'
        expect(rendered).to have_text user.exhibits.first.title
      end

      it 'does not include a tab for unpublished exhibits' do
        render

        expect(rendered).to have_css '.nav-tabs'
        expect(rendered).to have_no_link 'Unpublished exhibits'
      end

      it 'does not include a tab for preview exhibits' do
        render

        expect(rendered).to have_css '.nav-tabs'
        expect(rendered).to have_no_link 'Preview exhibits'
      end
    end

    context 'with a site admin' do
      let(:user) { FactoryBot.create(:site_admin) }

      before do
        allow(view).to receive_messages(can?: true, new_exhibit_path: '/exhibits/new')
      end

      it 'includes a tab with unpublished exhibits' do
        render

        expect(rendered).to have_css '.nav-tabs'
        expect(rendered).to have_link 'Unpublished exhibits'
        expect(rendered).to have_text exhibit_c.title
      end

      it 'includes a tab with preview (unlisted) exhibits' do
        render

        expect(rendered).to have_link 'Preview exhibits', href: '#unlisted'
        expect(rendered).to have_css '#unlisted .exhibit-card', text: exhibit_d.title
        expect(rendered).to have_no_css '#published .exhibit-card', text: exhibit_d.title
      end
    end
  end

  context 'with an authorized user' do
    let(:user) { FactoryBot.build(:site_admin) }

    before do
      allow(view).to receive_messages(can?: true,
                                      new_exhibit_path: '/exhibits/new')
    end

    it 'gives instructions for getting started' do
      render

      expect(rendered).to include 'Welcome to Spotlight!'
      expect(rendered).to have_link 'Create Exhibit', href: '/exhibits/new'
    end

    it 'has a sidebar with a button to create a new exhibit' do
      render

      expect(view.content_for(:sidebar)).to have_css '.btn', text: 'Create a new exhibit'
    end
  end
end
