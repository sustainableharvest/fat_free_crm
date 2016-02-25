class PurchaseContract < ActiveRecord::Base
  validates_presence_of :contract_number
  validates :rits_id, presence: true, uniqueness: true

  # Pulls Spot Contracts from RITS, formats into hash based on PurchaseContract model
  def self.rits_pcs
    url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    data = JSON.parse(open(url).read)
    data.each do |pc| 
      pc["rits_id"] = pc.delete "id"
      pc["arrival_month"] = pc_name_to_month(pc["contract_number"])
      pc["sold"] = false
      pc["spot"] = true
    end
  end

  # Creates new PCs from RITS, updates sold PCs from RITS
  def self.spot_update
    existing_pcs = PurchaseContract.all.map {|pc| pc.rits_id}
    rits_pcs.each do |pc|
      PurchaseContract.find_or_create_by(rits_id: pc["rits_id"]) do |contract|
        contract.update_attributes(pc)
        contract.save!
        existing_pcs.delete(contract.rits_id)
      end
    end
    existing_pcs.each {|pc| PurchaseContract.where(rits_id: pc).update_attributes(sold: true) }
  end

  def self.recent_spots
    PurchaseContract.where("arrival_month > ?", 3.months.ago)
  end

end
