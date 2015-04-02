class CreateTvEpisodes < ActiveRecord::Migration
  def change
    create_table :tv_episodes do |t|
      t.string :name, null: false
      t.references :media_file
      t.integer :subtitles_file_id, limit: 4
      t.references :tv_season

      t.timestamps null: false
    end
  end
end
