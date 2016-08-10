ltc.each do |contact|
  match = Contact.where(email: contact["Email Address"])
  if match.empty?  
    c = Contact.create(first_name: contact["Name"], last_name: contact["Last Name"], email: contact["Email Address"])
    c.addresses << Address.create(country: contact["COUNTRY"], address_type: "Business")
    c.comments << Comment.create(user_id: 1, commentable_type: "Contact", comment: "FROM IMPORT\n\nCountry: " + contact["COUNTRY"].to_s + "\n\nType: " + contact["CONTACT TYPE"].to_s + "\n\nCompany: " + contact["Company"].to_s)
    c.tag_list = "LTC2014"
    c.save
  end  
end

roasters.each do |roaster|
  match = Contact.where(email: roaster["Email Address"])
  if match
    match.each do |n|
      n.assignee = User.where(email: roaster["Assigned to (use email)"]).first if roaster["Assigned to (use email)"].present?
      n.tag_list.add("LTC2016Target")
      n.save
    end
  end
end