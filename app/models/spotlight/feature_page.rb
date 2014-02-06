module Spotlight
  class FeaturePage < Spotlight::Page
    has_many   :child_pages, :class_name  => "Spotlight::FeaturePage",
                             :foreign_key => "parent_page_id"

    belongs_to :parent_page, :class_name  => "Spotlight::FeaturePage"
  end
end
