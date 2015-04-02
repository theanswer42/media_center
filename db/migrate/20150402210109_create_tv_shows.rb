class CreateTvShows < ActiveRecord::Migration
  def change
    create_table :tv_shows do |t|
      t.string :name, null: false
      t.references :tv_library

      t.timestamps null: false
    end
  end
end
