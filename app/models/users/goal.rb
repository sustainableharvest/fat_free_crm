class Goal < ActiveRecord::Base
  belongs_to :user

  before_save :check_month_uniqueness

  validates :bags, numericality: true, allow_blank: true

  def check_month_uniqueness
    if Goal.where(user: self.user).where("extract(year from date) = ?", self.date.year).where("extract(month from date) = ?", self.date.month).exists?
      errors.add(:date, "User already has goal for this month.")
      return false
    else
      return true
    end
  end

end