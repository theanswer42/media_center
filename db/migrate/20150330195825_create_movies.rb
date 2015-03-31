class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :name, null: false
      t.references :media_file
      t.integer :subtitles_file_id, limit: 4
      t.references :movie_library
      
      t.timestamps null: false
    end

    add_index :movies, [:movie_library_id, :media_file_id]
  end
end
