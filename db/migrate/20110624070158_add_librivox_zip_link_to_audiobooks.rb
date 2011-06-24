class AddLibrivoxZipLinkToAudiobooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :librivox_zip_link, :text
  end

  def self.down
    remove_column :audiobooks, :librivox_zip_link
  end
end