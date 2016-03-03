class CreateExpandPlans < ActiveRecord::Migration
  def change
    create_table :expand_plans do |t|

      t.timestamps null: false
    end
  end
end
