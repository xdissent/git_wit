class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :path
      t.references :user
      t.boolean :public

      t.timestamps
    end
    add_index :repositories, :path
    add_index :repositories, :user_id
  end
end
