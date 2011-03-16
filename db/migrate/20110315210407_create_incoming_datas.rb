class CreateIncomingDatas < ActiveRecord::Migration
  def self.up
    create_table :incoming_datas do |t|
      t.text :json_data
      t.boolean :processed, :default => false, :null => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :incoming_datas
  end
end
