class CreatePublicKeys < ActiveRecord::Migration
  def change
    create_table :public_keys do |t|
      t.references :user
      t.text :content
      t.string :comment

      t.timestamps
    end
    add_index :public_keys, :user_id
    add_index :public_keys, :content, :unique => true
  end
end
