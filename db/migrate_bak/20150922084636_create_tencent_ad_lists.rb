class CreateTencentAdLists < ActiveRecord::Migration
  def change
    create_table :tencent_ad_lists do |t|
    	t.integer :tag_id, comment: '广告位ID'
    	t.string :tag_name, comment: '广告位名称'
    	t.integer :width, comment: '广告位宽度'
    	t.integer :height, comment: '广告位高'
    	t.decimal :min_cpm, comment: '广告位CPM起拍价' 
    	t.text :block_vacation,comment:'广告位限制的行业'
    	t.text :allow_file, comment: '广告位上传支持素材的文件格式'
    	t.string :enable, comment:"广告位支持与否"
    	t.string :screen, comment: '广告位的屏次'
    	t.string :review_pic,comment:'资质路径url'
    	t.string :tag_quality, comment:'精品资源'
      	t.timestamps null: false
    end
  end
end
