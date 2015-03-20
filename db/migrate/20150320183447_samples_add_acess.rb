class SamplesAddAcess < ActiveRecord::Migration
  def change
    add_column :samples, :access, :string, :limit => 8
  end
end
