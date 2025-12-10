class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  def new
    @user = User.new
  end

  def edit
    @user = User.find(session[:user_id])
  end

  def update
    @user = User.find(session[:user_id])
    @user.update(user_params)
    if @user.save
      redirect_to "/"
    else
      render :edit
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to "/"
    else
      render :new
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:email_address, :username, :password, :password_confirmation)
  end
end
