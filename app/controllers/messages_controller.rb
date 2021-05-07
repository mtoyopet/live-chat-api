class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    messages = Message.includes(:user)
    mesages_array = messages.map do |message|
      {
        id: message.id,
        user_id: message.user.id,
        name: message.user.name,
        content: message.content,
        created_at: message.created_at
      }
    end

    render :json => mesages_array, :status => :ok
  end
end
