class PurchaseContract < ActiveRecord::Base
  validates_presence_of :contract_number
  validates :rits_id, presence: true, uniqueness: true
end
