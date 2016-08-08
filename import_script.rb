ltc.each do |contact|
  match = Contact.where(email: contact["Email Address"])
  if match.empty?  
    c = Contact.create(first_name: contact["Name"], last_name: contact["Last Name"], email: contact["Email Address"])
    c.comments << Comment.create(user_id: 1, commentable_type: "Contact", comment: "FROM IMPORT\n\n" + contact["COUNTRY"].to_s + "\n\n " + contact["CONTACT TYPE"].to_s + "\n\n " + contact["Company"].to_s)
    c.tag_list= "LTC2014"
    c.save
  end  
end  