class ChangeSspToDecimal < ActiveRecord::Migration
  def change
    change_column :purchase_contracts, :ssp, :decimal
    change_column :purchase_contracts, :fob, :decimal
  end
end
