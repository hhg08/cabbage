class CreateOriginalities < ActiveRecord::Migration
  def change
    create_table :originalities do |t|

      t.timestamps null: false
    end
  end
end
