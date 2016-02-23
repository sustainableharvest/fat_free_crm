module SamplesHelper

  def opportunity_state_checkbox(state, count)
    entity_filter_checkbox(:state, state, count)
  end

  def rits_purchase_contracts
    url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    JSON.parse(open(url).read)
  end

  def rits_pc_names
    pc_names = []
    rits_purchase_contracts.each {|pc| pc_names << pc["contract_number"]}
    pc_names << nil
  end

  def rits_pc_hash
    pc_hash = {}
    rits_purchase_contracts.each {|pc| pc_hash[pc["contract_number"]] = {:country => pc["country"], :ssp => pc["ssp"], :fob_price => pc["fob"], :rits_id => pc["id"], :producer => pc["producer"], :month => name_to_month(pc["contract_number"])}}
    pc_hash
  end

  def name_to_month(name)
    Date.strptime(name.gsub(/[A-z]/,""), '%m-%d-%Y')
  end
end