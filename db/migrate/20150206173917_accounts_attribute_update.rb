class AccountsAttributeUpdate < ActiveRecord::Migration
  def up
    add_column :accounts, :type, :string, :limit => 32
    add_column :accounts, :status, :string, :limit => 32
    add_column :accounts, :rits_id, :string, :limit => 64
    add_column :accounts, :google_docs, :text

    add_column :accounts, :salesforce_id, :string, :limit => 32
    add_column :contacts, :salesforce_id, :string, :limit => 32
  end 

  def down
    remove_column :accounts, :type
    remove_column :accounts, :status
    remove_column :accounts, :rits_id
    remove_column :accounts, :google_docs

    remove_column :accounts, :salesforce_id
    remove_column :contacts, :salesforce_id
  end
end
