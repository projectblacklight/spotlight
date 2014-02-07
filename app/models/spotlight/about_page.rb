module Spotlight
  class AboutPage < Spotlight::Page

    before_save do
      self.display_sidebar = true
    end

  end
end
