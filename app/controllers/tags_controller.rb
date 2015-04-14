class TagsController < ApplicationController
  before_action :require_user
  before_action :set_current_tab, only: [:index, :show]  

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
  end

end