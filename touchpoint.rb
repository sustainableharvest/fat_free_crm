deadline = 30.days.ago
users = [36, 3, 8]

# add to account class
# returns if last activity is more recent than deadline
def recent_history(deadline)
  Version.history(self).first.created_at > deadline
end

def salesperson_check(user_id, deadline)
  inactive = []
  accounts = Account.where(assigned_to: user_id)
  accounts.each do |account|
    inactive.push(account.id) if !account.recent_history(30.days.ago)
  end
  inactive
end

katy.each do |acc|
  
end