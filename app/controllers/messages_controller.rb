class MessagesController < ApplicationController
  def index
    @messages = Message.includes(:user).all

    render :json => @messages, :status => :ok
  end
end
