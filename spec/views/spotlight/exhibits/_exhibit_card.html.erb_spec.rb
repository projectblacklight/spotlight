# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/_exhibit_card.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:p) { 'spotlight/exhibits/exhibit_card' }

  before do
    allow(view).to receive_messages(exhibit_path: '/')
  end

  context 'for an exhibit without a thumbnail' do
    before do
      exhibit.update(thumbnail_id: nil)
    end

    it 'has a placeholder thumbnail' do
      render(p, exhibit:)

      expect(rendered).to have_css 'img.default-thumbnail'
    end
  end

  it 'has a thumbnail' do
    render(p, exhibit:)

    expect(rendered).to have_css 'img'
  end

  it 'has a title' do
    render(p, exhibit:)

    expect(rendered).to have_css '.card-title', text: exhibit.title
  end

  context 'for an exhibit with a description' do
    before do
      exhibit.update(description: 'Test <b>description</b> & more.')
    end

    it 'has a description that strips html tags' do
      render(p, exhibit:)

      expect(rendered).to have_css '.description', text: 'Test description & more.'
    end

    it 'converts the description with the configured search class' do
      upcase_search_class = Class.new(Spotlight::ExhibitSearch) do
        def self.plain_text(html)
          super.upcase
        end
      end
      allow(Spotlight::Engine.config).to receive(:exhibit_search_class).and_return(-> { upcase_search_class })

      render(p, exhibit:)

      expect(rendered).to have_css '.description', text: 'TEST DESCRIPTION & MORE.'
    end
  end

  context 'with a search query' do
    let(:exhibit) { FactoryBot.create(:exhibit, title: 'Some Title', subtitle: 'Some Subtitle', description: 'Some <b>description</b>') }

    it 'marks the matches in the title, subtitle, and description' do
      render(p, exhibit:, exhibit_search: Spotlight::ExhibitSearch.new('some'))

      expect(rendered).to have_css '.card-title mark', text: 'Some'
      expect(rendered).to have_css '.subtitle mark', text: 'Some'
      expect(rendered).to have_css '.description mark', text: 'Some'
    end
  end

  context 'for an unpublished exhibit' do
    before do
      exhibit.update(published: false)
    end

    it 'has an unpublished banner' do
      render(p, exhibit:)

      expect(rendered).to have_css '.badge.unpublished', text: 'Unpublished'
    end
  end
end
