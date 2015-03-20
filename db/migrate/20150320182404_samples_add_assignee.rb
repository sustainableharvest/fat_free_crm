class SamplesAddAssignee < ActiveRecord::Migration
  def change
    add_column :samples, :assigned_to, :integer

    add_index :samples, :assigned_to
  end
end
