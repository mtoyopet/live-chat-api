class Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    super
  end

  private

  def sign_up_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
