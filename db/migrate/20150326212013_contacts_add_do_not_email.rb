class ContactsAddDoNotEmail < ActiveRecord::Migration
  def change
    add_column :contacts, :do_not_email, :boolean
  end
end
