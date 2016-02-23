class AddSpotandSoldToPurchaseContracts < ActiveRecord::Migration
  def change
    add_column :purchase_contracts, :spot, :boolean
    add_column :purchase_contracts, :sold, :boolean
  end
end
