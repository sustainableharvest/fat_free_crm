class CreateContactCampaigns < ActiveRecord::Migration
  def change
    create_table :contact_campaings, :force => true do |t|
      t.references :contact
      t.references :campaign
      t.datetime   :deleted_at
      t.timestamps
    end
  end
end
