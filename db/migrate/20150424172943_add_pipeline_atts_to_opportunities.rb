class AddPipelineAttsToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :sales_price_per_lb,  :float
    add_column :opportunities, :origin,              :string
    add_column :opportunities, :terms,               :integer
    add_column :opportunities, :delivery_month,      :date
    add_column :opportunities, :bag_weight,          :integer
    add_column :opportunities, :payment_terms,       :integer
    add_column :opportunities, :hidden_probability,  :integer
  end
end
