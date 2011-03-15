class ChangeReviewDetailsToReviewContent < ActiveRecord::Migration
  def self.up
    change_table :reviews do |t|
      t.remove :detail
      t.text :content
    end
  end

  def self.down
    change_table :reviews do |t|
      t.remove :content
      t.string :detail
    end
  end
end
