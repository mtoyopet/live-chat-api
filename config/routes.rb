Rails.application.routes.draw do
  constraints format: :json do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      registrations: 'auth/registrations'
    }
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
