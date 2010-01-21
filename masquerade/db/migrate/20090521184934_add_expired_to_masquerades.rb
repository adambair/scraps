class AddExpiredToMasquerades < ActiveRecord::Migration
  def self.up
    add_column :masquerades, :expired, :boolean
  end

  def self.down
    remove_column :masquerades, :expired
  end
end
