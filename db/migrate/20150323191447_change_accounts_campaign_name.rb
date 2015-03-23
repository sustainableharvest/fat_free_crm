class ChangeAccountsCampaignName < ActiveRecord::Migration
  def change
    rename_table :accounts_campaign, :accounts_campaigns
  end
end
