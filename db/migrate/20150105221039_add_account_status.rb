class AddAccountStatus < ActiveRecord::Migration
  def up
    add_column :accounts, :status, :string
  end

  def down
    remove_column :accounts, :status
  end
end
