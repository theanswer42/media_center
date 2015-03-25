class AddScannedAtToMediaLibrary < ActiveRecord::Migration
  def change
    add_column :media_libraries, :scanned_at, :datetime
  end
end
