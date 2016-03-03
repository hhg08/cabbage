class CreateExpandAdOriginalities < ActiveRecord::Migration
  def change
    create_table :expand_ad_originalities do |t|

      t.timestamps null: false
    end
  end
end
