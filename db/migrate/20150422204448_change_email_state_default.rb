class ChangeEmailStateDefault < ActiveRecord::Migration
  def change
    change_column_default :emails, :state, "Collapsed"
  end
end
