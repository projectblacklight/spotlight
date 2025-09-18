# frozen_string_literal: true

RSpec.describe Spotlight::RenderingHelper, type: :helper do
  describe '#sir_trevor_markdown' do
    it 'renders basic markdown as html' do
      expect(helper.render_markdown('Here is some **styled text**.').chomp).to match(%r{<p>Here is some <strong>styled text</strong>.</p>})
    end

    it 'add heading ids automatically' do
      expect(helper.render_markdown('## Test Header').chomp).to match(%r{<h2 id="test-header">Test Header</h2>})
    end
  end
end
