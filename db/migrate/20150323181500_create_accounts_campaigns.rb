class CreateAccountsCampaigns < ActiveRecord::Migration
  def change
    create_table :accounts_campaigns do |t|
      t.references :account
      t.references :campaign
      t.datetime   :deleted_at
      t.timestamps
    end
  end
end
