class Sample < ActiveRecord::Base
  belongs_to :opportunity
  belongs_to :user

  serialize :subscribed_users, Set

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail :ignore => [ :subscribed_users ]
  has_fields
  exportable
  sortable :by => ["created_at DESC"], :default => "created_at DESC"

  has_ransackable_associations %w(opportunities tags comments)
  ransack_can_autocomplete

  validates_presence_of :state
  validates_presence_of :pricing_type
  validates :description, length: { maximum: 255 }

  validates_numericality_of :quoted_price, :allow_nil => true, :if => :spot?
  validates :rits_purchase_contract_id, :presence => true, :if => :spot?

  validates :differential, :numericality => true, :presence => true, :allow_nil => true, :if => :not_spot?
  validates :sh_fee, :numericality => true, :presence => true, :allow_nil => true, :if => :not_spot?
  validates :differential, :numericality => true, :presence => true, :allow_nil => true, :if => :not_spot?
  validates :producer, :presence => true, :if => :not_spot?

  def spot?
    pricing_type == "spot"
  end

  def not_spot?
    pricing_type != "spot"
  end

  def short_state
    short = state.gsub("sample_", "")
    short = short.gsub("_approval", "").titleize.truncate(13)
  end

end