class TagsController < ApplicationController
  before_action :require_user
  before_action :set_current_tab, only: [:index, :show]  

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @taggings = get_taggings(@tag)
  end

  def get_taggings(tag)
    tags = []
    tag.taggings.each do |tagging|
      tags << tagging.taggable_type.constantize.find(tagging.taggable_id)
    end
    tags
  end

end