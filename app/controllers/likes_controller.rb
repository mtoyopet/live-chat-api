class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_like, only: :destroy

  def create
    like = Like.new(message_id: params[:id], user_id: current_user.id)

    if like.save
      render :json => { id: like.id, email: current_user.uid }, :status => :ok
    else
      render :json => {}, :status => :bad_request
    end
  end

  def destroy
    if @like.destroy
      render :json => { id: @like.id, email: @like.user.uid }, :status => :ok
    else
      render :json => { message: @like.errors.messages }, :status => :bad_request
    end
  end

  private 

  def set_like
    @like = Like.find(params[:id])
  end

end
