class SamplesController < EntitiesController

  before_filter :load_settings

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])
  end

  def show
    @timeline = timeline(@sample)
    @pricing = Setting.unroll(:sample_pricing)
  end

  def new
    opp = params[:related].split('_').last.to_i
    url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    @purchase_contracts =  JSON.parse(open(url).read)
    # Outline of converting it to better hash
    # pc_hash = {}quit
    # results.each {|pc| pc_hash[pc["contract_number"]] = pc["country"], pc["ssp"]}
    pc_names = []
    @purchase_contracts.each {|pc| pc_names << pc["contract_number"]}
    @pc_names = pc_names
    binding.pry
    @sample.attributes = {:user => current_user, :opportunity => Opportunity.find(opp)}
    @pricing = Setting.unroll(:sample_pricing)
  end

  def create
    binding.pry
    @comment_body = params[:comment_body]
    url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    @purchase_contracts =  JSON.parse(open(url).read)
    if @sample.rits_purchase_contract_id
      @sample.fob_price = @purchase_contracts.where()
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
    url = "https://rits.sustainableharvest.com/api/v1/spot_contracts.json"
    @purchase_contracts =  JSON.parse(open(url).read)
    binding.pry
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