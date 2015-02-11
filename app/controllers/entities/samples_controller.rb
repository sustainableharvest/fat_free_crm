class SamplesController < EntitiesController

  before_filter :load_settings

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])
  end

  def show
    
  end

  def new
    # binding.pry
    if params[:related]
      opp = params[:related].split('_').last.to_i
    end
    # binding.pry
    @sample.attributes = {:user => current_user, :opportunity => Opportunity.find(opp)}
    @pricing = Setting.unroll(:sample_pricing)
  end

  def create
    # binding.pry
    @comment_body = params[:comment_body]

    if @sample.save
      @sample.add_comment_by_user(@comment_body, current_user)
    else
      @pricing = Setting.unroll(:sample_pricing)
    end
  end

  def edit
    @pricing = Setting.unroll(:sample_pricing)
  end

  def update
    binding.pry
    @sample.update_attributes(params[:sample])
  end

  def destroy
    # binding.pry
    # opportunity = @sample.opportunity
    @sample.destroy

    respond_with(@sample) do |format|
      format.html { respond_to_destroy(:html) }
      # format.js   { respond_to_destroy(:ajax) }
    end
  end

  private

    alias :get_samples :get_list_of_records

  #----------------------------------------------------------------------------
  def load_settings
    @state = Setting.unroll(:sample_state)
  end

  def respond_to_destroy(method)
    # binding.pry
    if method == :ajax
      puts 'UH OH SPAGHETTIO'
    else
      if @sample.producer.empty?
        flash[:notice] = t(:msg_asset_deleted, @sample.rits_purchase_contract_id)
      else
        flash[:notice] = t(:msg_asset_deleted, @sample.producer)
      end
    redirect_to opportunity_path(@sample.opportunity)
    end

  end

end