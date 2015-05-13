# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: opportunities
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

class Opportunity < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_one    :account_opportunity, dependent: :destroy
  has_one    :account, through: :account_opportunity
  has_many   :contact_opportunities, dependent: :destroy
  has_many   :contacts, -> { order("contacts.id DESC").distinct }, through: :contact_opportunities
  has_many   :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_many   :emails, as: :mediator
  has_many   :samples, :dependent => :destroy

  serialize :subscribed_users, Set

  scope :state, ->(filters) {
    where('stage IN (?)' + (filters.delete('other') ? ' OR stage IS NULL' : ''), filters)
  }
  scope :created_by,  ->(user) { where('user_id = ?', user.id) }
  scope :assigned_to, ->(user) { where('assigned_to = ?', user.id) }
  scope :won,         -> { where("opportunities.stage = 'closed_won'") }
  scope :lost,        -> { where("opportunities.stage = 'closed_lost'") }
  scope :not_lost,    -> { where("opportunities.stage <> 'closed_lost'") }
  scope :pipeline,    -> { where("opportunities.stage IS NULL OR (opportunities.stage != 'closed_won' AND opportunities.stage != 'closed_lost')") }
  scope :unassigned,  -> { where("opportunities.assigned_to IS NULL") }

  # Search by name OR id
  scope :text_search, ->(query) {
    if query =~ /\A\d+\z/
      where('upper(name) LIKE upper(:name) OR opportunities.id = :id', name: "%#{query}%", id: query)
    else
      search('name_cont' => query).result
    end
  }

  scope :visible_on_dashboard, ->(user) {
    # Show opportunities which either belong to the user and are unassigned, or are assigned to the user and haven't been closed (won/lost)
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', user_id: user.id).where("opportunities.stage != 'closed_won'").where("opportunities.stage != 'closed_lost'")
  }

  scope :by_closes_on, -> { order(:closes_on) }
  scope :by_amount,    -> { order('opportunities.amount DESC') }

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  has_fields
  exportable
  sortable by: ["name ASC", "amount DESC", "amount*probability DESC", "probability DESC", "closes_on ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w(account contacts tags campaign activities emails comments)
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_opportunity_name
  validates_numericality_of :discount, allow_nil: true
  validates :amount, :numericality => { :greater_than => 0 }
  validates :probability, numericality: true, inclusion: { in: 0..100, 
                                                           :message => :between_0_100 }
  validate  :users_for_shared_access
  validates :stage, inclusion: { in: proc { Setting.unroll(:opportunity_stage).map { |s| s.last.to_s } } }, allow_blank: true
  validates :origin, presence: true, inclusion: { in: proc { Setting.unroll(:opportunity_origin).map { |s| s.last.to_s } } }
  validates_presence_of :delivery_month
  validates :payment_terms, presence: true, inclusion: { in: proc { Setting.unroll(:opportunities_payment_terms).map { |s| s.last.to_s } } }
  validates :sales_price_per_lb, :presence => true, :numericality => true
  validates :amount, :presence => true, :numericality => true
  validates_presence_of :closes_on
  validates :sh_fee, :presence => true, :numericality => true

  before_save :default_assigned_to

  after_create  :increment_opportunities_count
  after_destroy :decrement_opportunities_count

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end
  def self.default_stage
    Setting[:opportunity_default_stage].try(:to_s) || 'prospecting'
  end

  #----------------------------------------------------------------------------
  def weighted_amount
    ((amount || 0) - (discount || 0)) * (probability || 0) / 100.0
  end

  # Backend handler for [Create New Opportunity] form (see opportunity/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    # Quick sanitization, makes sure Account will not search for blank id.
    params[:account].delete(:id) if params[:account][:id].blank?
    account = Account.create_or_select_for(self, params[:account])
    self.account_opportunity = AccountOpportunity.new(account: account, opportunity: self) unless account.id.blank?
    self.account = account
    self.campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    result = save
    contacts << Contact.find(params[:contact]) unless params[:contact].blank?
    result
  end

  # Backend handler for [Update Opportunity] form (see opportunity/update).
  #----------------------------------------------------------------------------
  def update_with_account_and_permissions(params)
    if params[:account] && (params[:account][:id] == "" || params[:account][:name] == "")
      self.account = nil # Opportunity is not associated with the account anymore.
    elsif params[:account]
      self.account = Account.create_or_select_for(self, params[:account])
    end
    # Must set access before user_ids, because user_ids= method depends on access value.
    self.access = params[:opportunity][:access] if params[:opportunity][:access]
    self.attributes = params[:opportunity]
    save
  end

  # Attach given attachment to the opportunity if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      send(attachment.class.name.tableize) << attachment
    end
  end

  # Discard given attachment from the opportunity.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts
      send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, params)
    opportunity = Opportunity.new(params)

    # Save the opportunity if its name was specified and account has no errors.
    if opportunity.name? && account.errors.empty?
      # Note: opportunity.account = account doesn't seem to work here.
      opportunity.account_opportunity = AccountOpportunity.new(account: account, opportunity: opportunity) unless account.id.blank?
      if opportunity.access != "Lead" || model.nil?
        opportunity.save
      else
        opportunity.save_with_model_permissions(model)
      end
    end
    opportunity
  end

  # CREATED BY SCOTT
  # Returns total amount for all opportunities, or for all opportunities with a certain stage
  # ------------------------------------------------------------------------------------------------
  def self.total_amounts(scope = all)
    result = 0
    if scope == all
      Opportunity.my.each { |opp| result += opp.amount if opp.amount }
    else
      Opportunity.my.where(:stage => scope.to_s ).each { |opp| result += opp.amount if opp.amount }
    end
    result
  end

  # ------------------------------------------------------------------------------------------------
  def default_assigned_to
    if assigned_to.blank?
      if account.id.blank?
        self.assigned_to = user_id
      else
        account.assigned_to.blank? ? self.assigned_to = account.user_id : self.assigned_to = account.assigned_to
      end
    end
  end

  # Opportunity Reporting methods
  # ------------------------------------------------------------------------------------------------
  def probability_percent
    probability.to_f / 100.0
  end

  def total_lbs
    amount * bag_weight
  end

  def total_revenue(weighted = 1.0)
    total_lbs * sales_price_per_lb * weighted
  end

  def total_from_sh_fee(weighted = 1.0)
    total_lbs * sh_fee * weighted
  end

  def cash_breakdown
    if payment_terms == "net_40" || payment_terms == "net_30"
      return self.total_revenue(self.probability_percent) / 5.0
    elsif payment_terms == "cash"
      return self.total_revenue(self.probability_percent) / 4.0
    else 
      return self.total_revenue(self.probability_percent)
    end
  end

  def sales_breakdown
    if payment_terms == "cad"
      return self.total_revenue(self.probability_percent) * 1.0
    else
      return self.total_revenue(self.probability_percent) / 4.0
    end
  end

  def revenue_checking
    amount && bag_weight && payment_terms && sales_price_per_lb && probability && sh_fee && user.email != "marcus@sustainableharvest.com"
  end

  def payment_split
    case self.payment_terms
    when "cad"
      return (-2..-2)
    when "cash"
      return (0..3)
    else
      return (0..4)
    end
  end

  def self.revenue_by_month(type)
    report = Hash.new
    opps = Opportunity.delivery_by_month
    opps.each do |month, oppors|
      oppors.each do |oppor|
        if oppor.revenue_checking 
          type == "cash" ? amount = oppor.cash_breakdown : amount = oppor.sales_breakdown
          type == "cash" ? range = oppor.payment_split : oppor.payment_terms == "cad" ? range = (-2..-2) : range = (0..3)
          range.each do |h|
            if report[month.next_month(h)]
              report[month.next_month(h)] += amount
            else
              report.store(month.next_month(h), amount)
            end
          end 
        end  
      end
    end
    report
  end

  def self.revenue_to_csv(type)
    report = Opportunity.revenue_by_month(type)
    arr = []
    report.each do |date, revenue|
      arr << [date, revenue]
    end
    arr = arr.sort {|a,b| a[0] <=> b[0]}
    arr.each {|i| i[0] = i[0].strftime('%B %Y')}
    CSV.generate do |csv|
      csv << arr.map { |h| h[0] }
      csv << arr.map { |j| j[1] }
    end
  end

  def self.delivery_by_month
    ops = Hash.new
    Opportunity.pipeline.each do |opp|
      if opp.delivery_month
        month_year = Date.new(opp.delivery_month.year, opp.delivery_month.month, 1)
        if ops[month_year]
          ops[month_year] << opp
        else
          ops.store(month_year, [opp])
        end
      end
    end
    binding.pry
    ops
  end

  # def self.value_by_stage
  #   report = {}
  #   Opportunity.pipeline.each do |opp|

  #   end
  # end

  # def self.incoming_revenue(weighted = false, target = nil)
  #   revenue = 0
  #   Opportunity.pipeline.each do |opp|
  #     weighted ? rev = opp.total_revenue(opp.probability_percent) : rev = opp.total_revenue
  #     if target.present?
  #       revenue += rev if opp.delivery_month.month == target
  #     else
  #       revenue += rev
  #     end
  #   end
  #   revenue.to_i
  # end

  private

  # Make sure at least one user has been selected if the contact is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_opportunity) if self[:access] == "Shared" && !permissions.any?
  end

  #----------------------------------------------------------------------------
  def increment_opportunities_count
    if campaign_id
      Campaign.increment_counter(:opportunities_count, campaign_id)
    end
  end

  #----------------------------------------------------------------------------
  def decrement_opportunities_count
    if campaign_id
      Campaign.decrement_counter(:opportunities_count, campaign_id)
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_opportunity, self)
end
