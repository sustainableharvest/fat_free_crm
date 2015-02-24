Account.all.each do |acc|
  if !acc.website.blank?
    if acc.website.include?("https://")
      a = acc.website.gsub("https://", "http://")
      acc.update_attributes(:website => a) 
    elsif !acc.website.include?("http://") 
      acc.update_attributes(:website => "http://" + acc.website)
    end
  end
end