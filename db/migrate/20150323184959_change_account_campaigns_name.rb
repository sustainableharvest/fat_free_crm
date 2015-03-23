class ChangeAccountCampaignsName < ActiveRecord::Migration
  def change
    rename_table :account_campaigns, :accounts_campaign
  end
end
