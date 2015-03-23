class AccountsCampaigns < ActiveRecord::Base
  belongs_to :account
  belongs_to :campaign
  validates_presence_of :account_id, :campaign_id

  ActiveSupport.run_load_hooks(:fat_free_crm_accounts_campaigns, self)
end