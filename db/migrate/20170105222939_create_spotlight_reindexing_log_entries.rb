class CreateSpotlightReindexingLogEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :spotlight_reindexing_log_entries do |t|
      t.integer :items_reindexed_count
      t.integer :items_reindexed_estimate
      t.datetime :start_time
      t.datetime :end_time
      t.integer :job_status
      t.references :exhibit
      t.references :user

      t.timestamps
    end
  end
end
