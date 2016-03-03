class CreateExpandAds < ActiveRecord::Migration
  def change
    create_table :expand_ads do |t|

      t.timestamps null: false
    end
  end
end
