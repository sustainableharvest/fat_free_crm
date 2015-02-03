class SamplesController < EntitiesController

  def index
    @samples = get_samples(:page => params[:page], :per_page => params[:per_page])
  end

  def show
    
  end

  def new
    
  end

  def create
    
  end

  def edit

  end

  def destroy
    
  end

  private

    alias :get_samples :get_list_of_records

end