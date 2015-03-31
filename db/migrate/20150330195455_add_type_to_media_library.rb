class AddTypeToMediaLibrary < ActiveRecord::Migration
  def change
    add_column :media_libraries, :type, :string, null: false, default: "MovieLibrary"
  end
end
