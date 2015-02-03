class CreateSamplesTable < ActiveRecord::Migration
  def up
    create_table :samples do |t|
    end
  end

  def down
    drop_table :samples
  end
end
