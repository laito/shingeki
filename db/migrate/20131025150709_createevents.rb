class Createevents < ActiveRecord::Migration
  def change
  	create_table :events do |t|
      t.string :title
      t.string :description
      t.string :deadline
      t.integer :user_id
      t.integer :acceptor_id
      t.integer :status
      t.string :tip
      t.timestamp :deadline
      t.string :eventtype
      t.timestamps
    end
  end
end
