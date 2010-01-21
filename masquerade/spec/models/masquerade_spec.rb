require File.dirname(__FILE__) + '/../spec_helper'

describe Masquerade do

  context "Validations" do
    before do
      @masq = Masquerade.new
    end

    it {@masq.should have_validation_error("can't be blank").on(:admin_id)}
    it {@masq.should have_validation_error("can't be blank").on(:user_id)}
  end

  context 'Token' do
    before do
      @admin = Factory(:dmt_user)
      @user  = Factory(:dmt_user)
      @masq  = Masquerade.create(:admin => @admin, :user => @user)
    end
    
    it 'should generate a token upon creation' do
      @masq.token.should_not be_nil
    end

    it 'should only be valid for 8 hours' do
      @masq.expired?.should == false
      @masq.update_attributes(:created_at => 9.hours.ago)
      @masq.expired?.should == true
    end
  end

  context 'Users' do
    before do
      @admin = Factory(:dmt_user)
      @user  = Factory(:dmt_user)
      @masq  = Masquerade.create(:admin => @admin, :user => @user)
    end

    it 'should have an admin' do
      @masq.admin.should == @admin
    end

    it 'should have an user' do
      @masq.user.should == @user
    end
  end
end
