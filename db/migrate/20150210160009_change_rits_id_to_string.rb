class ChangeRitsIdToString < ActiveRecord::Migration
  def change
    change_column :samples, :rits_purchase_contract_id, :string
  end
end
