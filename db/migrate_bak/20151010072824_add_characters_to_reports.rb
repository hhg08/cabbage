class AddCharactersToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :dsp_order_id, :string
  	add_column :reports, :date, :string
  	add_column :reports, :lid, :string
  	add_column :reports, :bid, :integer
  	add_column :reports, :suc_bid, :integer
  	add_column :reports, :pv, :integer
  	add_column :reports, :click, :integer
  	add_column :reports, :amount, :integer
  end
end
