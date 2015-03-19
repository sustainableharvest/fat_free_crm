class ChangeContactCampaignsName < ActiveRecord::Migration
  def change
    rename_table :contact_campaings, :contact_campaigns
  end
end
