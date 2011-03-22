class RenameIncomingDataTable < ActiveRecord::Migration
  def self.up
    rename_table('incoming_datas', 'incoming_data')
  end

  def self.down
    rename_table('incoming_data', 'incoming_datas')
  end
end
