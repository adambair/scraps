class CreateMasquerades < ActiveRecord::Migration
  def self.up
    create_table :masquerades do |t|
      t.integer  :admin_id
      t.integer  :user_id
      t.text     :token
      t.timestamps
    end
  end

  def self.down
    drop_table :masquerades
  end
end
