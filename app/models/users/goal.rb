class Goal < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :bags
  validates_presence_of :date

end