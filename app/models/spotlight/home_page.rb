module Spotlight
  class HomePage < Spotlight::Page
    before_save do
      self.display_sidebar = true
    end

  end
end
