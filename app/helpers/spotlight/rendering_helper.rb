# frozen_string_literal: true

module Spotlight
  module RenderingHelper # :nodoc:
    def render_markdown(text)
      GitHub::Markup.render('.md', text).html_safe
    end
  end
end
