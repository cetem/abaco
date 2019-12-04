class WithdrawsController < ApplicationController

  def index
    @withdraws = Withdraw.all
  end

  def create
    movement = Withdraw.create_movement(params[:id], current_user.id)

    if movement.persisted?
      @withdraw_id = params[:id]
    else
      @url = new_movement_path(withdraw_id: params[:id])
    end
  end
end
