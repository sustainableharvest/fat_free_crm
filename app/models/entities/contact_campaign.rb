class ContactCampaign < ActiveRecord::Base
  belongs_to :contact
  belongs_to :campaign
  validates_presence_of :contact_id, :campaign_id

  ActiveSupport.run_load_hooks(:fat_free_crm_contact_campaign, self)
end
