class Sample < ActiveRecord::Base

  belongs_to :opportunity
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  has_many   :tasks, :as => :asset, :dependent => :destroy
  has_many   :emails, :as => :mediator

  serialize :subscribed_users, Set

  scope :state, ->(filters) {
    where('state IN (?)' + (filters.delete('other') ? ' OR state IS NULL' : ''), filters)
  }

  scope :text_search, ->(query) { search('name' => query).result }

  before_save :follow_up_default

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  has_fields
  exportable
  sortable :by => ["created_at DESC", "opportunity_id DESC"], :default => "opportunity_id DESC"

  has_ransackable_associations %w(opportunities tags comments)
  ransack_can_autocomplete

  validates_presence_of :state
  # validates_presence_of :pricing_type
  validates :description, length: { maximum: 255 }
  # validates :sh_fee, :numericality => true, :presence => true

  # Validations for Spot Pricing
  # validates :quoted_price, :allow_nil => true
  # validates :rits_purchase_contract_id, :presence => true, :if => :spot?

  # Validations for Forward Pricing
  # validates :differential, :numericality => true, :presence => true, :allow_nil => true, :if => :not_spot?
  validates :producer, :presence => true, :if => :not_spot?
  # validates :delivery_month, :presence => true, :if => :not_spot?

  # Validations for Shipment and Follow Up
  validates :shipment_date, :presence => true, :if => :sample_shipped?

  # Discard given attachment from the account.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts, Opportunities
      send(attachment.class.name.tableize).delete(attachment)
    end
  end  

  def sample_shipped?
    self.state != "sample_requested"
  end

  def spot?
    self.pricing_type == "Spot"
  end

  def not_spot?
    self.pricing_type != "Spot"
  end

  def short_state
    short = state.gsub("sample_", "")
    short = short.gsub("_approval", "").titleize.truncate(13)
  end

  def name
    self.rits_purchase_contract_id.present? ? self.rits_purchase_contract_id : self.producer
  end

  def overdue?
    today = Date.today
    self.follow_up_date.present? ? self.follow_up_date <= today : false
  end

  def complete?
    self.state == "rejected" || self.state == "approved"
  end

  def follow_up_default
    today = Date.today
    default = today + 14
    case self.state
      when 'sample_requested'
      self.follow_up_date = default if self.follow_up_date.blank?
      when "sample_shipped", "pending_approval"
      self.follow_up_date = self.shipment_date + 14 if self.follow_up_date.blank?
      # when "rejected", "approved"
      #   self.follow_up_date = nil
    end
  end

end