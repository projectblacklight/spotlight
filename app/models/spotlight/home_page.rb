module Spotlight
  class HomePage < Spotlight::Page
    before_save do
      self.display_sidebar = true
      self.published = true
    end

  end
end
