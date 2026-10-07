# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/index', type: :view do
  let(:exhibits) { Spotlight::Exhibit.none }
  let(:published_exhibits) { exhibits.published.page(1) }

  let(:ability) { Ability.new(user) }
  let(:user) { Spotlight::Engine.user_class.new }

  before do
    assign(:exhibits, exhibits)
    assign(:published_exhibits, published_exhibits)
    allow(view).to receive_messages(exhibits_path: '/', exhibit_path: '/', current_user: user, current_ability: ability, container_classes: 'container')
  end

  context 'with published exhibits' do
    let!(:exhibit_a) { FactoryBot.create(:exhibit, published: true) }
    let!(:exhibit_b) { FactoryBot.create(:exhibit, published: true) }
    let!(:exhibit_c) { FactoryBot.create(:exhibit, published: false) }

    let(:exhibits) { Spotlight::Exhibit.all }

    it 'renders the published exhibits' do
      render

      expect(rendered).to have_css('.exhibit-card', count: 2)
      expect(rendered).to have_text exhibit_a.title
      expect(rendered).to have_text exhibit_b.title
      expect(rendered).to have_no_text exhibit_c.title

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

    it 'renders a search form above the main content' do
      render

      search = view.content_for(:header_content)
      expect(search).to have_css 'search form[method="get"]'
      expect(search).to have_css 'label.visually-hidden[for="exhibit-search-q"]', text: 'Search exhibits', visible: :all
      expect(search).to have_field 'Search exhibits', type: 'search', with: '', placeholder: 'Find exhibits by title or description'
      expect(search).to have_css '[role="status"]#exhibit-search-status.visually-hidden', text: ''
    end

    context 'with a search query' do
      let(:query) { 'maps' }

      before do
        exhibit_a.update(title: 'Early Maps', subtitle: 'Of the Americas', tag_list: ['a'])
        exhibit_c.update(title: 'Unpublished Maps')
        controller.params[:q] = query
        assign(:published_exhibits, Spotlight::ExhibitSearch.new(query).paginate(exhibits.published, page: 1))
        allow(view).to receive(:exhibits_path) { |**params| "/?#{params.compact.to_query}" }
      end

      it 'renders only the matching exhibits, with the query highlighted' do
        render

        expect(rendered).to have_css('.exhibit-card', count: 1)
        expect(rendered).to have_css '.exhibit-card .card-title mark', text: 'Maps'
        expect(rendered).to have_no_text exhibit_b.title
      end

      it 'fills in the form and reports the number of matches' do
        render

        search = view.content_for(:header_content)
        expect(search).to have_field 'Search exhibits', with: 'maps'
        expect(search).to have_css '#exhibit-search-status', text: '1 exhibit matches “maps”.'
      end

      it 'keeps the query in the tag links' do
        render

        expect(rendered).to have_link 'a', href: '/?q=maps&tag=a'
        expect(rendered).to have_link 'All', href: '/?q=maps'
      end

      it 'disables the tags without any matches' do
        exhibit_b.update(tag_list: ['b'])
        render

        expect(rendered).to have_link 'a'
        expect(rendered).to have_no_link 'b'
        expect(rendered).to have_css '.tags .nav-link.disabled[aria-disabled="true"]:not([href])', text: 'b'
      end

      context 'when nothing matches in the selected tag' do
        before do
          exhibit_b.update(tag_list: ['b'])
          controller.params[:tag] = 'b'
          assign(:published_exhibits, Spotlight::ExhibitSearch.new(query).paginate(exhibits.published.tagged_with('b'), page: 1))
        end

        it 'keeps the selected tag enabled and says nothing matches' do
          render

          expect(rendered).to have_css '.tags .nav-link.active', text: 'b'
          expect(rendered).to have_link 'a'
          expect(rendered).to have_text 'No exhibits match “maps”.'
        end
      end

      context 'when nothing matches' do
        let(:query) { 'zzz' }

        it 'says so' do
          render

          expect(rendered).to have_no_css '.exhibit-card'
          expect(rendered).to have_text 'No exhibits match “zzz”.'
        end

        it 'disables every tag except the selected one' do
          exhibit_b.update(tag_list: ['b'])
          controller.params[:tag] = 'b'
          render

          expect(rendered).to have_css '.tags .nav-link.disabled', text: 'All'
          expect(rendered).to have_css '.tags .nav-link.disabled', text: 'a'
          expect(rendered).to have_css '.tags .nav-link.active:not(.disabled)', text: 'b'
        end
      end

      context 'with a site admin' do
        let(:user) { FactoryBot.create(:site_admin) }

        before do
          allow(view).to receive_messages(can?: true, new_exhibit_path: '/exhibits/new')
        end

        it 'filters each tab and gives each tab its own status message' do
          render

          expect(rendered).to have_link 'Published exhibits', exact_text: true
          expect(rendered).to have_link 'Unpublished exhibits', exact_text: true
          expect(rendered).to have_css '#unpublished .exhibit-card mark', text: 'Maps'
          expect(rendered).to have_css '#published[data-exhibit-search-status="1 published exhibit matches “maps”."]'
          expect(rendered).to have_css '#unpublished[data-exhibit-search-status="1 unpublished exhibit matches “maps”."]'
          expect(view.content_for(:header_content)).to have_css '#exhibit-search-status', exact_text: '1 published exhibit matches “maps”.'
        end
      end
    end

    context 'with paginated exhibits' do
      let(:published_exhibits) { exhibits.published.page(1).per(1) }

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
