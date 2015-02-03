class AddProducerToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :state, :string, :limit => 32
    add_column :samples, :opportunity_id, :integer
    add_column :samples, :type, :string, :limit => 32
    add_column :samples, :description, :string, :limit => 255
    add_column :samples, :rits_purchase_contract_id, :integer
    add_column :samples, :pricing_type, :string, :limit => 12
    add_column :samples, :producer, :string, :limit => 64
    add_column :samples, :quoted_price, :decimal, :precision => 8, :scale => 2
    add_column :samples, :sh_margin, :decimal, :precision => 8, :scale => 2
    add_column :samples, :sh_fee, :decimal, :precision => 8, :scale => 2
    add_column :samples, :differential, :decimal, :precision => 8, :scale => 2
    add_column :samples, :delivery_month, :date
    add_column :samples, :fob_price, :decimal, :precision => 8, :scale => 2
  end
end
