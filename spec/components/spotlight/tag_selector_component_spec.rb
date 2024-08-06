# frozen_string_literal: true

RSpec.describe Spotlight::TagSelectorComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(field_name: 'tags', all_tags:, selected_tags_value:) }

  context 'with no existing tags' do
    let(:all_tags) { [] }
    let(:selected_tags_value) { nil }

    it 'displays the no results message' do
      expect(rendered).to have_css('label.no-results')
    end
  end

  context 'with existing tags' do
    let(:all_tags) { %w[Birds Cats Dogs] }
    let(:selected_tags_value) { 'Cats,Dogs' }

    it 'has an input with the currently selected tags' do
      expect(rendered).to have_css('input[name="tags"][value="Cats,Dogs"]')
    end

    it 'has a target for the selected tag pills' do
      expect(rendered).to have_css('div[data-tag-selector-target="selectedTags"]')
    end

    it 'has checkboxes for selecting and creating tags' do
      expect(rendered).to have_css('input[type="checkbox"]:not([checked])[data-tag="Birds"]')
      expect(rendered).to have_css('input[type="checkbox"][checked][data-tag="Cats"]')
      expect(rendered).to have_css('input[type="checkbox"][checked][data-tag="Dogs"]')
      expect(rendered).to have_css('input[type="checkbox"][disabled][data-tag-selector-target="newTag"][data-tag=""]')
    end
  end
end
