task :sales_inactivity => :environment do
  [36, 3, 8].each { |n| UserMailer.inactive_accounts(User.find(n)).deliver }
end