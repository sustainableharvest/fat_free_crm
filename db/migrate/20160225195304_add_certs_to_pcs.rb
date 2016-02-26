class AddCertsToPcs < ActiveRecord::Migration
  def change
    add_column :purchase_contracts, :fair_trade, :boolean
    add_column :purchase_contracts, :fair_trade_usa, :boolean
    add_column :purchase_contracts, :rainforest, :boolean
    add_column :purchase_contracts, :fair_for_life, :boolean
    add_column :purchase_contracts, :organic, :boolean
    add_column :purchase_contracts, :average_score, :float
    add_column :purchase_contracts, :description, :string
  end
end
