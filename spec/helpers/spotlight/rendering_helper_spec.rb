# frozen_string_literal: true

RSpec.describe Spotlight::RenderingHelper, type: :helper do
  describe '#render_markdown' do
    it 'renders basic markdown as html' do
      expect(helper.render_markdown('Here is some **styled text**.').chomp).to match(%r{<p>Here is some <strong>styled text</strong>.</p>})
    end

    it 'renders strikethrough markdown as html' do
      expect(helper.render_markdown('This is ~~struck~~ text.').chomp).to match(%r{<p>This is <del>struck</del> text.</p>})
    end

    it 'add heading ids automatically' do
      expect(helper.render_markdown('## Test Header').chomp).to include('<h2 id="test-header">Test Header</h2>')
    end
  end
end
