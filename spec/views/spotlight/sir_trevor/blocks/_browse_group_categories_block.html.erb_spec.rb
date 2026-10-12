# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_browse_group_categories_block.html.erb', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/browse_group_categories_block' }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { instance_double(Spotlight::FeaturePage, display_sidebar?: true) }
  let(:searches) do
    %w[dogs cats birds pigs tigers].map { |title| FactoryBot.create(:published_search, exhibit:, title:) }
  end
  let(:unpublished_search) { FactoryBot.create(:search, exhibit:, title: 'turtles') }
  let(:group) { FactoryBot.create(:group, exhibit:, title: 'Pets', published: true, searches: [unpublished_search, *searches]) }
  let(:data) { {} }
  let(:block) do
    assign(:page, page)
    SirTrevorRails::Blocks::BrowseGroupCategoriesBlock.new({ type: 'block', data: }, page)
  end

  before do
    allow(view).to receive_messages(current_exhibit: exhibit, exhibit_browse_groups_path: '/browse/group')
    allow(block).to receive(:groups).and_return([group])
  end

  it 'renders up to 4 published browse categories for each group' do
    render partial:, locals: { browse_group_categories_block: block }
    expect(rendered).to have_css 'h2', text: 'Pets'
    expect(rendered).to have_css '.categories-4'
    expect(rendered).to have_css '.category-title', count: 4
    expect(rendered).to have_css '.category-title', text: 'dogs'
    expect(rendered).to have_no_css '.category-title', text: 'turtles'
    expect(rendered).to have_no_css '.item-count'
  end

  context 'when configured to display item counts' do
    let(:data) { { 'display-item-counts' => 'true' } }

    it 'shows the number of items in each browse category' do
      render partial:, locals: { browse_group_categories_block: block }
      expect(rendered).to have_css '.item-count', text: /\d+ items/, count: 4
    end
  end
end
