class PasswordResetsController < ApplicationController

  # step 1. the "enter your email to get a new password" template
  def new
  end

  # step 2. sends the password reset email
  def create
    login = Login.find_user(params[:email])

    login.send_password_reset if login

    # Success notice is sent whether we found a user or not. This is to mislead bad people.
    @message = "We've just sent you an email with a link to reset your password!"
    render "password_reset_status"
  end

  # step 3. template for updating the password
  def edit
    @login = Login.find_by_password_reset_token!(params[:id])
  end

  # step 4. the update operation
  def update
    @login = Login.find_by_password_reset_token!(params[:id])

    if @login.password_reset_sent_at < 3.hours.ago
      redirect_to new_password_reset_path, :notice => "Oops, we had to expire your password reset request for security reasons. Just issue a new one and make sure you click the new password link in the email whithin the next hour or so."
    elsif @login.update_attributes(params[:login])
      @message = "And boom, we saved your new password!"
      render "password_reset_status"
    else
      render "edit"
    end
  end

end
