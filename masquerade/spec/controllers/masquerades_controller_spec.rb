require File.dirname(__FILE__) + '/../spec_helper'

describe MasqueradesController do
  before do
    @user = Factory(:dmt_user)
  end

  context 'admin' do
    before(:each) do
      @admin = Factory(:dmt_user)
      @admin.stub!(:admin?).and_return(true)
      controller.stub!(:current_user).and_return(@admin)
    end

    it 'should require an admin' do
      post :create, :user_id => @user.id
      response.should redirect_to('/')
    end

    it 'should set a flash notice on success' do
      post :create, :user_id => @user.id
      response.flash[:notice].should_not be_nil
    end

    it 'should set a flash error on failure' do
      post :create, :user_id => 'non-existant_user_id'
      response.flash[:error].should_not be_nil
    end

    it 'should create a new Masquerade' do
      lambda {post :create, :user_id => @user.id}.should change(Masquerade, :count).by(1)
    end

    it 'should set the masquerade_token in the session' do
      post :create, :user_id => @user.id
      response.session[:masquerade_token].should == assigns[:masq].token
    end

    it 'should change the current_user to the masqueradee' do
      post :create, :user_id => @user.id
      assigns[:current_user].should == @user
    end
  end

  context 'transition back to admin' do
    before do
      @admin = Factory(:dmt_user)
      @admin.stub!(:admin?).and_return(true)
      controller.stub!(:current_user).and_return(@user)
      @masq = Masquerade.create(:admin_id => @admin.id, :user_id => @user.id)
      controller.session[:masquerade_token] = @masq.token
    end

    it 'should redirect to / on failure' do
      Masquerade.stub!(:find_by_token_and_user_id).and_return(nil)
      delete :destroy, :user_id => @user.id
      response.should redirect_to('/')
    end

    it 'should not allow expired masquerades' do
      @masq.update_attributes(:created_at => 5.days.ago)
      delete :destroy, :user_id => @user.id
      response.should redirect_to('/')
    end

    it 'should inform the user upon failure' do
      Masquerade.stub!(:find_by_token_and_user_id).and_return(nil)
      delete :destroy, :user_id => @user.id
      response.flash[:error].should_not be_nil
    end

    it 'should find the masquerade_token from session' do
      Masquerade.should_receive(:find_by_token_and_user_id).and_return(@masq)
      delete :destroy, :user_id => @user.id
    end

    it 'should change the current_user back to the admin' do
      delete :destroy, :user_id => @user.id
      assigns[:current_user].should == @admin
    end

    it 'should remove the masquerade_token from session' do
      delete :destroy, :user_id => @user.id
      session[:masquerade_token].should be_nil
    end

    it 'should expire the masqerade' do
      @masq.expired?.should == false
      delete :destroy, :user_id => @user.id
      assigns[:masq].expired?.should == true
    end

    it 'should redirect back to the users list after transition' do
      delete :destroy, :user_id => @user.id
      response.should redirect_to(users_path)
    end

    it 'should let the user know the transition has occured' do
      delete :destroy, :user_id => @user.id
      response.flash[:notice].should_not be_nil
    end
  end

  context 'non-admin' do
    before do
      @nonadmin = mock_model(DmtUser, :admin? => false)
      controller.stub!(:current_user).and_return(@nonadmin)
    end

    it 'should require an admin' do
      post :create, :user_id => @user.id
      response.should redirect_to(new_session_path)
    end
  end
end
