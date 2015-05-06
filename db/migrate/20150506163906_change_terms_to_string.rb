class ChangeTermsToString < ActiveRecord::Migration
  def change
    change_column :opportunities, :payment_terms, :string
    add_column    :opportunities, :sh_fee, :decimal, :precision => 8, :scale => 2
  end
end
