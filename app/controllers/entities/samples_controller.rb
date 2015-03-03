class SamplesController < EntitiesController

  before_filter :load_settings

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])
  end

  def show
    # binding.pry
    @timeline = timeline(@sample)
    @pricing = Setting.unroll(:sample_pricing)
  end

  def new
    opp = params[:related].split('_').last.to_i
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
      flash[:error] = errors_format(@sample.errors.messages)
      # binding.pry
      redirect_to opportunity_path(@sample.opportunity)
    end
  end

  def edit
    # binding.pry
    @pricing = Setting.unroll(:sample_pricing)
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