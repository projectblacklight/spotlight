class UpdateJobLogEntry < ActiveRecord::Migration[5.1]
  def change
    add_column :spotlight_job_log_entries, :job_type, :string, :default => 'Reindexing'
    rename_column :spotlight_job_log_entries, :items_reindexed_count, :job_item_count
    rename_column :spotlight_job_log_entries, :items_reindexed_estimate, :job_items_estimate
  end
end
