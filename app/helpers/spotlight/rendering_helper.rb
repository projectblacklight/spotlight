# frozen_string_literal: true

module Spotlight
  module RenderingHelper # :nodoc:
    def render_markdown(text)
      # Extend Redcarpet renderer to add HTML anchors to each heading in the output HTML
      renderer = Redcarpet::Render::HTML.new(with_toc_data: true)
      # Use Redcarpet to render markdown as html (strikethrough enables ~~text~~)
      Redcarpet::Markdown.new(renderer, strikethrough: true).render(text).html_safe
    end
  end
end
