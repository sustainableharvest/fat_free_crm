class ChangeAccountsCampaignsName < ActiveRecord::Migration
  def change
    rename_table :accounts_campaigns, :account_campaigns
  end
end
