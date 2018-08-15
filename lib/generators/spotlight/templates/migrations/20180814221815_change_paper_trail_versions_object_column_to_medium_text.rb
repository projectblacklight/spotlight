##
# A migration that updates the object column size on PaperTrail's version table
# This is in a generator template because our migrations run before PaperTrail is installed
class ChangePaperTrailVersionsObjectColumnToMediumText < ActiveRecord::Migration[5.1]
  # See https://github.com/paper-trail-gem/paper_trail/blob/6c34a3dd5a5f8c1b042f458b7727c9d3bbf81a50/lib/generators/paper_trail/install/templates/create_versions.rb.erb#L5-L17
  # for rationale of the 1,073,741,823 byte limit

  def change
    change_column :versions, :object, :text, limit: 1_073_741_823
  end
end
