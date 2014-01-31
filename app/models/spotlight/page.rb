module Spotlight
  class Page < ActiveRecord::Base
    MAX_PAGES = 50
    has_many   :child_pages, :class_name  => "Spotlight::Page",
                             :foreign_key => "parent_page_id"

    belongs_to :parent_page, :class_name  => "Spotlight::Page"

    validates :weight, :inclusion => { :in => Proc.new{ 0..Spotlight::Page::MAX_PAGES } }

    default_scope { order("weight ASC") }
  end
end
