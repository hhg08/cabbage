class ChangeTagIdTypeForTencentAdLists < ActiveRecord::Migration
  def change
  	change_column :tencent_ad_lists,:tag_id,:string
  end
end
