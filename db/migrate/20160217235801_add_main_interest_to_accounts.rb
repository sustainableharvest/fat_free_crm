class AddMainInterestToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :main_interest, :string
  end
end
