class AddRitsIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :rits_id, :integer
    add_column :samples, :ssp, :integer
    add_column :samples, :country, :string
  end
end
