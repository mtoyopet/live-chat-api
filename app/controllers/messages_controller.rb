class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    messages = Message.includes(:user).last(50)
    mesages_array = messages.map do |message|
      {
        id: message.id,
        user_id: message.user.id,
        name: message.user.name,
        content: message.content,
        email: message.user.uid,
        created_at: message.created_at,
        likes: message.likes.map { |like| { id: like.id, email: like.user.uid }  }
      }
    end

    render :json => mesages_array, :status => :ok
  end
end
