class CreatePurchaseContracts < ActiveRecord::Migration
  def change
    create_table :purchase_contracts do |t|
      t.string :contract_number
      t.string :country
      t.integer :ssp
      t.integer :fob_price
      t.integer :rits_id
      t.string :producer
      t.datetime :arrival_month

      t.timestamps null: false
    end
  end
end
