class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.string :name
      t.string :path
      t.string :checksum
      t.references :media_library
      
      t.timestamps null: false
    end
  end
end
