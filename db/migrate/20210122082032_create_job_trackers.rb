# frozen_string_literal: true

class CreateJobTrackers < ActiveRecord::Migration[5.2]
  def change
    create_table :spotlight_job_trackers do |t|
      t.references :on, null: false, polymorphic: true, index: true
      t.references :resource, null: false, polymorphic: true, index: true
      t.string :job_id
      t.string :job_class
      t.string :parent_job_id
      t.string :parent_job_class
      t.string :status
      t.references :user
      t.text :log
      t.text :data

      t.timestamps
    end

    add_index :spotlight_job_trackers, :job_id
  end
end
