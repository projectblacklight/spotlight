class RenameReindexLogEntryToJobLogEntry < ActiveRecord::Migration[5.1]
  def self.up
    rename_table :spotlight_reindexing_log_entries, :spotlight_job_log_entries
  end

  def self.down
    rename_table :spotlight_job_log_entries, :spotlight_reindexing_log_entries
  end
end
