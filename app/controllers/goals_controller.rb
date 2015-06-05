class GoalsController < ApplicationController

  def edit_multiple
    @users = User.all
    @goals = Goal.all
  end

end