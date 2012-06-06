class AddUserHp < ActiveRecord::Migration
  def up
    add_column :users, :hp, :float, :default=>50.0
    User.update_all ["hp = ?", 50.0]
  end
  
  def down
    remove_column :users, :hp
  end
end
