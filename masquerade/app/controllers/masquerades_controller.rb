class MasqueradesController < ApplicationController
  before_filter :admin_required, :only => [:create]

  def create
    @user = DmtUser.find_by_id(params[:user_id])
    @masq = Masquerade.create(:admin => current_user, :user => @user) 
    if @user && @masq.valid?
      session[:masquerade_token] = @masq.token
      self.current_user = @user
      flash[:notice] = "You are successfully masqerading as #{@user.first_name} #{@user.last_name} (#{@user.login})"
      redirect_to '/'
    else
      flash[:error] = 'Unable to masquerade...'
      redirect_to users_path
    end
  end
  
  def destroy
    @masq = Masquerade.find_by_token_and_user_id(session[:masquerade_token], params[:user_id])
    if @masq && !@masq.expired?
      self.current_user = @masq.admin
      expire_masquerade!
      flash[:notice] = "Masquerade finished. You are now logged in as #{@masq.admin.login}"
      redirect_to users_path
    else
      flash[:error] = "Unable to finish masquerade."
      redirect_to '/'
    end
  end

  protected

  def expire_masquerade!
    @masq.expire!
    session[:masquerade_token] = nil
  end
end
