class CreateAccountSets < ActiveRecord::Migration
  def change
    create_table :account_sets do |t|

      t.string :mapping_url
      t.string :bid_url
      t.string :win_notice_url
      t.integer :qps
      t.string :no_cm_response
      t.string :rtb_msg_format
      t.string :use_tuserinfo
      t.timestamps null: false
    end
  end
end
