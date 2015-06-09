class AddGoalsModel < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :bags
      t.date    :date
      t.string  :comment

      t.timestamps
    end
  end
end
