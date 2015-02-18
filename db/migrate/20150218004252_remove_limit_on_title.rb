class RemoveLimitOnTitle < ActiveRecord::Migration
  def change
    change_column :contacts, :title, :string, :limit => 196
  end
end
