class UsersController < ApplicationController
  before_action :signed_in_user, only: [:show, :edit, :update]
  before_action :alredy_signed,  only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.registration_confirmation(@user).deliver
      flash[:success] = "Please confirm your email address to continue."
      redirect_back_or root_path
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to profile_path
    else
      render 'edit'
    end
  end

  def confirm_email
    user = User.find_by(confirm_token: params[:id])
    if user
      user.email_activate
      flash[:success] = "Welcome to the Fin App! Your email has been confirmed."
      sign_in user
      redirect_to root_path
    else
      flash.now[:danger] = "Sorry. User does not exist"
      redirect_to root_path
    end
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
