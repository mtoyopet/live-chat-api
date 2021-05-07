class MessagesController < ApplicationController
  def index
    @messages = Message.includes(:user).all
    mesages_array = @messages.map do |message|
      {
        user_id: message.user.id,
        name: message.user.name,
        content: message.content,
        created_at: message.created_at
      }
    end

    render :json => mesages_array, :status => :ok
  end
end
