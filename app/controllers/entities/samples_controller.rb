class SamplesController < EntitiesController
  include SamplesHelper
  before_filter :load_settings

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])
  end

  def show
    @timeline = timeline(@sample)
    @pricing = Setting.unroll(:sample_pricing)
  end

  def new
    opp = params[:related].split('_').last.to_i if params[:related]
    # @purchase_contracts = rits_purchase_contracts
    # Outline of converting it to better hash
    # pc_hash = {}
    # @purchase_contracts.each {|pc| pc_hash[pc["contract_number"]] = {:country => pc["country"], :ssp => pc["ssp"], :fob => pc["fob"], :rits_id => pc["id"], :producer => pc["producer"]}}
    # pc_names = []
    # @purchase_contracts.each {|pc| pc_names << pc["contract_number"]}
    @pc_names = rits_pc_names
    # binding.pry
    @sample.attributes = {:user => current_user, :opportunity => Opportunity.find(opp)}
    @pricing = Setting.unroll(:sample_pricing)
  end

  def create
    # binding.pry
    @comment_body = params[:comment_body]
    # url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    # @purchase_contracts =  JSON.parse(open(url).read)

    if rits_pc_hash.fetch(@sample.rits_purchase_contract_id, "Error") != "Error"
      info = rits_pc_hash.fetch(@sample.rits_purchase_contract_id)
      @sample.fob_price = info[:fob]
      @sample.producer  = info[:producer]
      @sample.description = info[:country] + ", Suggested Sales Price: " + info[:ssp].to_s
    end

    if @sample.save
      @sample.add_comment_by_user(@comment_body, current_user)
      redirect_to opportunity_path(@sample.opportunity)
    else
      flash[:error] = errors_format(@sample.errors.messages)
      # binding.pry
      redirect_to opportunity_path(@sample.opportunity)
    end
  end

  def edit
    @pc_names = rits_pc_names
    # binding.pry
    @pricing = Setting.unroll(:sample_pricing)
    respond_with(@sample)
  end

  def update
    @sample.update_attributes(params[:sample]) ? flash[:notice] = @sample.name + " updated." : flash[:error] = "Update Failed. " + errors_format(@sample.errors.messages)
      
    if request.referer.include?("sample")
      redirect_to sample_path(@sample)
    else
      redirect_to opportunity_path(@sample.opportunity)
    end
  end

  def destroy
    # binding.pry
    opportunity = @sample.opportunity
    @sample.destroy

    flash[:notice] = @sample.name + " has been deleted."

    redirect_to :back
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
  def load_settings
    @state = Setting.unroll(:sample_state)
  end

end