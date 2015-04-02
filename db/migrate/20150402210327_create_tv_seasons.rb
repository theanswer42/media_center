class CreateTvSeasons < ActiveRecord::Migration
  def change
    create_table :tv_seasons do |t|
      t.string :name
      t.references :tv_show
      
      t.timestamps null: false
    end
  end
end
