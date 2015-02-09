class AddSamplesShipmentInfo < ActiveRecord::Migration
  def change
    add_column :samples, :shipment_date, :date
    add_column :samples, :follow_up_date, :date
  end
end
