class CreateMediaLibraries < ActiveRecord::Migration
  def change
    create_table :media_libraries do |t|
      t.string :path
      t.string :name
      
      t.timestamps null: false
    end
  end
end
