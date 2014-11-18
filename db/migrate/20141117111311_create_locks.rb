class CreateLocks < ActiveRecord::Migration
  def change
    create_table :spotlight_locks do |t|
      t.references :on, polymorphic: true
      t.references :by, polymorphic: true
      t.timestamps
    end

    add_index :spotlight_locks, [:on_id, :on_type], unique: true
  end
end
