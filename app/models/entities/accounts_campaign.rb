class AccountsCampaign < ActiveRecord::Base
  belongs_to :account
  belongs_to :campaign
  validates_presence_of :account_id, :campaign_id
end