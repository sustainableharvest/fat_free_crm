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
      redirect_to opportunity_path(@sample.opportunity)
    else
      binding.pry
      redirect_to :action => "new", :controller => "samples", :sample => params[:sample]
    end
  end

  def edit

  end

  def destroy
    # binding.pry
    opportunity = @sample.opportunity
    @sample.destroy

    redirect_to :back
  end

  private

    alias :get_samples :get_list_of_records

  #----------------------------------------------------------------------------
  def load_settings
    @state = Setting.unroll(:sample_state)
  end

end