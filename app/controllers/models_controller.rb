class ModelsController < ApplicationController

  def typeahead
    render json: Models.where(name: params[:query])
  end

end