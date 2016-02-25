class RenamePurchaseContractFob < ActiveRecord::Migration
  def change
    rename_column :purchase_contracts, :fob_price, :fob
  end
end
