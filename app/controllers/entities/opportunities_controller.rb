# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class OpportunitiesController < EntitiesController
  before_action :load_settings
  before_action :get_data_for_sidebar, only: :index
  before_action :set_params, only: [:index, :redraw, :filter]
  before_action :set_hidden_vars, only: [:create, :update]

  # GET /opportunities
  #----------------------------------------------------------------------------
  def index
    @opportunities = get_opportunities(page: params[:page], per_page: params[:per_page])

    respond_with @opportunities do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @opportunities }
    end
  end

  # GET /opportunities/1
  # AJAX /opportunities/1
  #----------------------------------------------------------------------------
  def show
    @comment = Comment.new
    @timeline = timeline(@opportunity)
    respond_with(@opportunity)
  end

  # GET /opportunities/new
  #----------------------------------------------------------------------------
  def new
    @opportunity.attributes = { user: current_user, stage: Opportunity.default_stage, access: Setting.default_access, assigned_to: nil }
    @account     = Account.new(user: current_user, access: Setting.default_access)
    @accounts    = Account.my.order('name')

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
        @account = related.account if related.respond_to?(:account) && !related.account.nil?
        @campaign = related.campaign if related.respond_to?(:campaign)
      else
        respond_to_related_not_found(model) && return
      end
    end

    respond_with(@opportunity)
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    @account  = @opportunity.account || Account.new(user: current_user)
    @accounts = Account.my.order('name')

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Opportunity.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@opportunity)
  end

  # POST /opportunities
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@opportunity) do |_format|
      if @opportunity.save_with_account_and_permissions(params.permit!)
        @opportunity.add_comment_by_user(@comment_body, current_user)
        if called_from_index_page?
          @opportunities = get_opportunities
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @accounts = Account.my.order('name')
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(\d+)\z/
            @account = Account.find(Regexp.last_match[1]) # related account
          else
            @account = Account.new(user: current_user)
          end
        end
        @contact = Contact.find(params[:contact]) unless params[:contact].blank?
        @campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
      end
    end
  end

  # PUT /opportunities/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@opportunity) do |_format|
      if @opportunity.update_with_account_and_permissions(params.permit!)
        if called_from_index_page?
          get_data_for_sidebar
        elsif called_from_landing_page?(:accounts)
          get_data_for_sidebar(:account)
        elsif called_from_landing_page?(:campaigns)
          get_data_for_sidebar(:campaign)
        end
      else
        @accounts = Account.my.order('name')
        if @opportunity.account
          @account = Account.find(@opportunity.account.id)
        else
          @account = Account.new(user: current_user)
        end
      end
    end
  end

  # DELETE /opportunities/1
  #----------------------------------------------------------------------------
  def destroy
    if called_from_landing_page?(:accounts)
      @account = @opportunity.account   # Reload related account if any.
    elsif called_from_landing_page?(:campaigns)
      @campaign = @opportunity.campaign # Reload related campaign if any.
    end
    @opportunity.destroy

    respond_with(@opportunity) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /opportunities/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /opportunities/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /opportunities/redraw                                              AJAX
  #----------------------------------------------------------------------------
  def redraw
    @opportunities = get_opportunities(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@opportunities) do |format|
      format.js { render :index }
    end
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @opportunities = get_opportunities(page: 1, per_page: params[:per_page])
    respond_with(@opportunities) do |format|
      format.js { render :index }
    end
  end

  def cash_report
    send_data Opportunity.revenue_to_csv('cash'),
              filename: "Opportunities_Cash_Report.csv",
              type: "application/csv"
  end

  def sales_report
    send_data Opportunity.revenue_to_csv('sales'),
              filename: "Opportunities_Sales_Report.csv",
              type: "application/csv"
  end

  private

  #----------------------------------------------------------------------------
  alias_method :get_opportunities, :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        get_data_for_sidebar
        @opportunities = get_opportunities
        if @opportunities.blank?
          @opportunities = get_opportunities(page: current_page - 1) if current_page > 1
          render(:index) && return
        end
      else # Called from related asset.
        self.current_page = 1
      end
      # At this point render destroy.js
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @opportunity.name)
      redirect_to opportunities_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @opportunity.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      @opportunity_stage_total = HashWithIndifferentAccess[
                                 all: Opportunity.my.count,
                                 other: 0
      ]
      @opportunity_amount_total = {:all => Opportunity.total_amounts}
      staged_total = 0
      @stage.each do |value, key|
        @opportunity_stage_total[key] = Opportunity.my.where(:stage => key.to_s).count
        @opportunity_amount_total[key] = Opportunity.total_amounts(key)
        staged_total += Opportunity.total_amounts(key)
        @opportunity_stage_total[:other] -= @opportunity_stage_total[key]
      end
      @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
      @opportunity_amount_total[:other] = @opportunity_amount_total[:all] - staged_total
    end
  end

  #----------------------------------------------------------------------------
  def load_settings
    @stage = Setting.unroll(:opportunity_stage)
    @origin = Setting.unroll(:opportunity_origin)
  end

  #----------------------------------------------------------------------------
  def set_params
    current_user.pref[:opportunities_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:opportunities_sort_by]  = Opportunity.sort_by_map[params[:sort_by]] if params[:sort_by]
    session[:opportunities_filter] = params[:stage] if params[:stage]
  end

  #----------------------------------------------------------------------------
  def set_hidden_vars
    case @opportunity.origin
    when "columbia"
      @opportunity.bag_weight = 154
    when "rwanda", "ethiopia", "malawi", "tanzania"
      @opportunity.bag_weight = 132
    when "india"
      @opportunity.bag_weight = 110
    else
      @opportunity.bag_weight = 152
    end

    case @opportunity.stage
    when "initial_interest"
      @opportunity.hidden_probability = 20
    when "sampling"
      @opportunity.hidden_probability = 30
    when "reviewing_offer"
      @opportunity.hidden_probability = 50
    when "negotiation"
      @opportunity.hidden_probability = 70
    else
      @opportunity.hidden_probability = 100
    end
  end
end
