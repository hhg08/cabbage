class AddPlantformTencentToHqExpandAd < ActiveRecord::Migration
  def change
  	add_column :hq_expand_ad, :plantform_tencent,:integer,default: 0
  end
end
