class AddDspIdToAccountSets < ActiveRecord::Migration
  def change
  	add_column :account_sets, :dsp_id, :integer, :comment=>'账户配置的唯一性'
  end
end
