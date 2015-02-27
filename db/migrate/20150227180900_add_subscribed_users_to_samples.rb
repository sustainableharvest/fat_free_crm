class AddSubscribedUsersToSamples < ActiveRecord::Migration
  def change
    %w(samples).each do |table|
      add_column table.to_sym, :subscribed_users, :text
      # Reset the column information of each model
      table.singularize.capitalize.constantize.reset_column_information
    end
  end
end
