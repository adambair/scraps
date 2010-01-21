# == Schema Information
# Schema version: 20090521193023
#
# Table name: masquerades
#
#  id         :integer(11)     not null, primary key
#  admin_id   :integer(11)
#  user_id    :integer(11)
#  token      :text
#  created_at :datetime
#  updated_at :datetime
#  expired    :boolean(1)
#

class Masquerade < ActiveRecord::Base
  validates_presence_of :admin_id, :user_id, :token
  before_validation_on_create :set_token

  belongs_to :admin, :class_name => 'DmtUser'
  belongs_to :user, :class_name => 'DmtUser'

  def expired?
    self.expired = true if created_at < 8.hours.ago 
    super
  end

  def expire!
    self.expired = true
  end

  private

  def set_token
    self.token = make_token
  end

  # AB: Grabbed from RESTful Auth
  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end 
  
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
end
