errors_a = {}

a.each do |b|
  x = Account.new(:user => User.first, :name => b["name"], :website => b["website"], :phone => b["phone"], :fax => b["fax"], :email => b["email"], :category => b["category"], :salesforce_id => b["salesforce_id"], :account_type => "roaster", :status => "customer")
  if !x.save
    errors_a[x['salesforce_id']] = x.errors
  else
    b["addresses"].each do |addr|
      address = Address.create(:street1 => addr["street1"], :city => addr["city"], :state => addr["state"], :zipcode => addr["zipcode"], :country => addr["country"], :address_type => addr["address_type"].capitalize)
      x.addresses << address
    end
  end
  b["contacts"].each do |c|
    j = Contact.new(:user => User.first, :first_name => c["first_name"], :last_name => c["last_name"], :email => c["email"], :phone => c["phone"], :mobile => c["mobile"], :fax => c["fax"], :skype => c["skype"], :account => x, :title => c["title"], :department => c["department"])
    if !j.save
      errors_a[j['first_name']] = j.errors
    else
      if !c["addresses"].empty?
        y = Address.create(:street1 => c["addresses"].first["street1"], :city => c["addresses"].first["city"], :state => c["addresses"].first["state"], :zipcode => c["addresses"].first["zipcode"], :country => c["addresses"].first["country"], :address_type => c["addresses"].first["address_type"].capitalize)
        j.addresses << y
      end
    end
  end
end

errors_potentials = {}

potentials.each do |b|
  x = Account.new(:user => User.first, :name => b["name"], :website => b["website"], :phone => b["phone"], :fax => b["fax"], :email => b["email"], :category => b["category"], :salesforce_id => b["salesforce_id"], :account_type => "roaster", :status => "prospect")
  if !x.save
    errors_potentials[x['salesforce_id']] = x.errors
  else
    b["addresses"].each do |addr|
      address = Address.create(:street1 => addr["street1"], :city => addr["city"], :state => addr["state"], :zipcode => addr["zipcode"], :country => addr["country"], :address_type => addr["address_type"].capitalize)
      x.addresses << address
    end
  end
  b["contacts"].each do |c|
    j = Contact.new(:user => User.first, :first_name => c["first_name"], :last_name => c["last_name"], :email => c["email"], :phone => c["phone"], :mobile => c["mobile"], :fax => c["fax"], :skype => c["skype"], :account => x, :title => c["title"], :department => c["department"])
    if !j.save
      errors_potentials[j['first_name']] = j.errors
    else
      if !c["addresses"].empty?
        y = Address.create(:street1 => c["addresses"].first["street1"], :city => c["addresses"].first["city"], :state => c["addresses"].first["state"], :zipcode => c["addresses"].first["zipcode"], :country => c["addresses"].first["country"], :address_type => c["addresses"].first["address_type"].capitalize)
        j.addresses << y
      end
    end
  end
end



Account.all.each { |n| n.destroy } && Contact.all.each { |n| n.destroy } && Address.all.each { |n| n.destroy }

def add_address(type, addr)
  address = Address.new(:street1 => addr["street1"], :city => addr["city"], :state => addr["state"], :zipcode => addr["zipcode"], :country => addr["country"], :address_type => addr["address_type"])
  if !address.save
    errors[address["street1"]] = address.errors
  else
    type.addresses << address
  end
end