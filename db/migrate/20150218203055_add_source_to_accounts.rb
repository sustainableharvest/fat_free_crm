class AddSourceToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :source, :string, :limit => 64
  end
end
