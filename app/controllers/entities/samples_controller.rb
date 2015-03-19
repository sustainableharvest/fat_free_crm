class SamplesController < EntitiesController
  include SamplesHelper
  before_filter :load_settings
  before_filter :get_data_for_sidebar, :only => :index

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])

    respond_with @samples do |format|
      format.xls { render :layout => 'header'}
      format.csv { render :csv => @samples}
    end
  end

  def show
    @timeline = timeline(@sample)
    @pricing = Setting.unroll(:sample_pricing)
    respond_with(@sample)
  end

  def new
    opp = params[:related].split('_').last.to_i if params[:related]
    @pc_names = rits_pc_names
    @sample.attributes = {:user => current_user, :opportunity => Opportunity.find(opp)}
    # @pricing = Setting.unroll(:sample_pricing)
  end

  def create
    @comment_body = params[:comment_body]
    if rits_pc_hash.fetch(@sample.rits_purchase_contract_id, "Error") != "Error"
      info = rits_pc_hash.fetch(@sample.rits_purchase_contract_id)
      @sample.fob_price = info[:fob]
      @sample.producer  = info[:producer]
      @sample.rits_id = info[:rits_id]
      @sample.country = info[:country]
      @sample.ssp = info[:ssp]
    end

    # @sample.delivery_month = params[:date]

    if @sample.save
      @sample.add_comment_by_user(@comment_body, current_user)
      redirect_to opportunity_path(@sample.opportunity)
    else
      flash[:warning] = errors_format(@sample.errors.messages)
      redirect_to opportunity_path(@sample.opportunity)
    end
  end

  def edit
    @pc_names = rits_pc_names
    @pricing = Setting.unroll(:sample_pricing)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Sample.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end
    respond_with(@sample)
  end

  def update
    if rits_pc_hash.fetch(@sample.rits_purchase_contract_id, "Error") != "Error"
      info = rits_pc_hash.fetch(@sample.rits_purchase_contract_id)
      params[:sample].merge!(info)
    end
    @sample.update_attributes(resource_params) ? flash[:notice] = @sample.name + " updated." : flash[:error] = "Update Failed. " + errors_format(@sample.errors.messages)

    if request.referer.include?("sample")
      redirect_to sample_path(@sample)
    else
      redirect_to opportunity_path(@sample.opportunity)
    end
  end

  def destroy
    opportunity = @sample.opportunity
    @sample.destroy

    flash[:notice] = @sample.name + " has been deleted."
    if request.referer.include?("samples")
      redirect_to samples_path
    else
      redirect_to opportunity_path(opportunity)
    end
  end

  def filter
    session[:samples_filter] = params[:state]
    @samples = get_samples(:page => 1, :per_page => params[:per_page])

    respond_with(@samples) do |format|
      format.js { render :index}
    end
  end

  def redraw
    @samples = get_samples(page: 1, per_page: params[:per_page])
    set_options

    respond_with(@samples) do |format|
      format.js { render :index }
    end
  end

  def errors_format(errors)
    result = ""
    errors.each do |error, messages|
      messages.each do |message|
        result += error.to_s.capitalize + " " + message.to_s + ".\n"
      end  
    end
    result  
  end

  private

    alias :get_samples :get_list_of_records

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    @sample_state_total = { :all => Sample.my.count, :other => 0 }
    @state.each do |value, key|
      @sample_state_total[key] = Sample.my.where(:state => key.to_s).count
    end
  end

  def load_settings
    @state = Setting.unroll(:sample_state)
  end

end