class ChangeQuotedPriceToString < ActiveRecord::Migration
  def change
    change_column :samples, :quoted_price, :string
  end
end
