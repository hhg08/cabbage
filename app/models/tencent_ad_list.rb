#encoding:utf-8
require 'net/http'
require 'tx_upload_ads_info'
require 'pathname'
class TencentAdList < ActiveRecord::Base
	SETTING = YAML::load(File.read(File.expand_path('../../../config/adver_lists.yml', __FILE__)))
	SETTING_RABBIT = YAML::load(File.read(File.expand_path('../../../config/rabbitmq.yml', __FILE__)))
	COMPANY_IDS = SETTING["company"].keys
	ADVER_HASH = SETTING["company"]
	class << self
		#0 没有被tencent使用 1正在提交中 2提交完成 3提交审核中 4提交审核完成，等待审核 5审核通过 6审核不通过
		#腾讯素材定时上传
		def tencent_ad_material_upload
			sql = "select *, o.id as oid,o.id as oname,e.id as eid,`guige`,`source_type`,`source`,`source_yun` FROM hq_originality o LEFT JOIN (select * from hq_originality_exchange where plantform='tencent') e on o.id=e.originality_id WHERE `is_del` = 0 AND `status` = 0 AND `source_type` IN ('video','image','flash')"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			ids = results.map { |e| e["oid"]}
			ids.each do |id|
				upload_sigle_originality id
			end
		end

		#上传单个文件
		def upload_sigle_originality id
			originality = Originality.find id
			unless originality.nil?
				hqURL =  CGI.escape(originality["target_url"])
				company = Company.find(originality["company"])
				guige_arr=["1000x90","300x250","300x600","640x480","400x300","640x360","1280x720"]
				return if !(guige_arr.include? originality["guige"])
				company_id = originality["company"].to_i
				source_extname = Pathname.new(originality["source"]).extname
				if company&&!COMPANY_IDS.empty?&&(COMPANY_IDS.include? company_id)
					if Rails.env.to_s == "production"
						if (['.jpg','.png','.gif'].include? source_extname)
							file_url = originality["source_yun"]
						else
							file_url="http://dsp.hogic.cn/"+originality["source"]
						end
						targeting_url = "http://track.hogic.cn/api/ads?hqEvent=2&hqURL=#{hqURL}&hqSource=tencent&ext=${EXT}&impid=${AUCTION_IMP_ID}"
						monitor_url = ["http://track.hogic.cn/api/ads?hqEvent=1&hqSource=tencent&ext=${EXT}&hqPrice=${AUCTION_ENCRYPT_PRICE}&impid=${AUCTION_IMP_ID}"]
						url = "http://dsp.hogic.cn/"+originality["source"]+'#'+originality["id"].to_s
						client_name = ADVER_HASH[company_id]
					else
						if (['.jpg','.png','.gif'].include? source_extname)
							file_url = originality["source_yun"]
						else
							file_url="http://dev.dsp.hogic.cn/"+originality["source"]
						end
						targeting_url = "http://dev.track.hogic.cn/api/ads?hqEvent=2&hqURL=#{hqURL}&hqSource=tencent&ext=${EXT}&impid=${AUCTION_IMP_ID}"
						monitor_url = ["http://dev.track.hogic.cn/api/ads?hqEvent=1&hqSource=tencent&ext=${EXT}&hqPrice=${AUCTION_ENCRYPT_PRICE}&impid=${AUCTION_IMP_ID}"]
						url = "http://dev.dsp.hogic.cn/"+originality["source"]+'#'+originality["id"].to_s
						client_name = "浩趣信息科技（上海）有限公司"
					end
					order_info = {
						:dsp_order_id => originality["id"],
						:client_name => client_name,#{}"测试时平台：浩趣信息科技（上海）有限公司",#company.name,
						:file_url => file_url,
						:targeting_url => targeting_url,
						:monitor_url => monitor_url,
					}
					result1 = DSP::API::TxUploadAdsInfo.upload_material(order_info)
					p order_info
					p result1
					if result1["ret_code"].to_i == 0
						originality_exchange = OriginalityExchange.where("originality_id"=>originality["id"],"plantform"=>"tencent").first
						if originality_exchange
							originality_exchange.update_attributes({"status"=>4,"url"=>url,"originality_id"=>originality["id"]})
						else
							OriginalityExchange.create({"plantform"=>'tencent',"status"=>4,"url"=>url,"originality_id"=>originality["id"]})
						end
					end
				end
			end
		end
		#定时更新Tencent上传素材的状态
		def check_tencent_status
			sql = "select *, o.id as oid,o.id as oname,e.id as eid,`guige`,`source_type`,`source`,`source_yun` FROM hq_originality o LEFT JOIN (select * from hq_originality_exchange where plantform='tencent') e on o.id=e.originality_id WHERE `is_del` = 0 AND (status=4 OR status=5 OR status=6) AND `source_type` IN ('video','image','flash')"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			ids = results.map { |e| e["oid"]}
			ids.each do |id|
				check_single_originality_status id
			end
		end
		#单个查询
		def check_single_originality_status id
			messages = []
			originality = Originality.find(id)
			if originality
				response =  DSP::API::TxUploadAdsInfo.check_status(originality["id"])
				records = response["ret_msg"]["records"]
				unless records.nil?
					records.each do |value,key|
						record =  key[0]
						data_ad = {}
						status = 0
						case record["status"]
						when "审核不通过"
							# data_ad["checkstatus"] = 2
							status = 2
							update_origin(originality["id"],{"status"=>6,"reason"=>record["reason"]})
						when "审核通过"
							# data_ad["checkstatus"] = 1
							status = 1
							update_origin(originality["id"],{"status"=>5,"reason"=>"审核通过"})#本来没有更新原因
						when "待审核"
							# data_ad["checkstatus"] = 0
							update_origin(originality["id"],{"status"=>4,"reason"=>"待审核"})#本来没有更新原因
						end
						# expand_ad = ExpandAd.find(originality["aid"])
						# expand_ad.update_attributes(data_ad) if expand_ad
						if ["审核通过","审核不通过"].include? record["status"]
							messages << {oid:originality["id"],status:status,plantform:"tencent"}
						end
					end
				end
			end
			publish_originality_messages(messages.to_json) if !messages.empty?
		end

		#广告位信息同步-----数据每天定时更新一次 tencent_ad_list
		def task_update_tencent_ad_list
			date = Date.today - 1
			# date = '2015-09-18'
			result = DSP::API::AdsInfoSync.download(date)
			p result
			if result["ret_code"].to_i == 0
				records = result["ret_msg"]["records"] if result["ret_msg"]
				records.each do |record|
					width = record["style"].split('*').first
					height = record["style"].split('*').last
					location_id = record["location_id"]||record[:location_id]
					params = {
						tag_id: record["location_id"],
						tag_name: record["location_name"],
						width: width,
						height: height,
						min_cpm:record["cpm_start_pirce"],
						block_vacation:record["block_vacation"],
						allow_file:record["allow_file"],
						enable:record["enable"],
						screen:record["screen"],
						review_pic:record["review_pic"],
						tag_quality:record["loc_quality"],
					}
					tencent_ad_list = TencentAdList.where(:tag_id=>location_id).first #不是唯一，有pc端移动端区别
					if tencent_ad_list.nil?
						tencent_ad_list= TencentAdList.new(params)
						tencent_ad_list.save
					else
						tencent_ad_list.update_attributes(params)
					end
				end
			end
		end

		# #腾讯报表  --用于定时任务调取
		def task_get_tencent_report
			date = (Date.today-1).to_s
			day_of_tencent_report(date)
		end

		#获取一天数据
		def day_of_tencent_report(date)
			p date
			start_date = date
			end_date = date
			result = DSP::API::Report.download(start_date, end_date)
			if result["ret_code"].to_i != 0
				raise "请求错误 #{result}"
			end
			#更新报表数据模型字段
			records = result["ret_msg"]["records"]
			records.each do |key, value|
				dsp_order_id = key
				datas = key["start_date"]
				if !datas.nil?
					datas.each do |data|
						params = {}
						params["dsp_order_id"] = dsp_order_id
						params["date"] = start_date
						params["lid"] = data["lid"]
						params["bid"] = data["bid"]
						params["suc_bid"] = data["suc_bid"]
						params["pv"] = data["pv"]
						params["click"] = data["click"]
						params["amount"] = data["amount"]
						report = Report.where({"dsp_order_id"=>dsp_order_id,"date"=>start_date}).first
						if !report.nil?
							report.update_attributes(params)
						else
							Report.create(params)
						end
					end
				end
			end
		end

		#更新素材状态
		def update_origin(id,data)
			originality_exchange = OriginalityExchange.where("originality_id"=>id,"plantform"=>"tencent").first
			originality_exchange.update_attributes(data) if originality_exchange
		end

		def publish_originality_messages(messages)
			if Rails.env.to_s == "production"
				conn = Bunny.new(SETTING_RABBIT["connection"]["production"].symbolize_keys).tap(&:start)
			else
				conn = Bunny.new(SETTING_RABBIT["connection"]["development"].symbolize_keys).tap(&:start)
			end
			# conn.start
			ch = conn.create_channel
			q = ch.queue("task_update_originality_status",durable:true)
			q.publish(messages,persistent:true)
			conn.close
		end


		def get_tracking_url(hqAdId,hqCreativeId,hqSource='youku',hqEvent=1)
		    sql = "select *,hq_expand_ad.id as aid from hq_expand_ad left join hq_expand_plan on hq_expand_ad.plan=hq_expand_plan.id where hq_expand_ad.id=#{hqAdId}"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
		    result = results[0]
		    hqClientId = result['company']
		    hqAdId = result['aid']
		    hqGroupId = result['plan']
		    # $hqCreativeId = $result['originality'];
		     return "http://track.hogic.cn/api/ads?hqClientId=#{hqClientId}&hqGroupId=#{hqGroupId}&hqAdId=#{hqAdId}&hqCreativeId=#{hqCreativeId}&hqSource=#{hqSource}&hqEvent=#{hqEvent}"
		end
	end


#---------------------------------------------------------------------------------------------分割线----








	# DSP_ID = '190'
	# TOKEN = '73553e669b7270a4934706f76a99ad36'
	# AD_LIST_URL = 'http://opentest.adx.qq.com/location/list' #广告位信息同步API
	# UPLOAD_ORDER_URl = 'http://opentest.adx.qq.com/order/sync' #广告信息同步API
	# DENY_STATUS_URL = 'http://opentest.adx.qq.com/file/denylist' #获取审核未通过的广告信息API
	# GET_STARTUS_URL = 'http://opentest.adx.qq.com/order/getstatus' #批量获取广告的审核状态
	# UPLOAD_CUSTOMER_INFO_URL = 'http://opentest.adx.qq.com/client/sync' #批量上传客户信息审核
	# GET_CUSTOMER_STATUS_URL= 'http://opentest.adx.qq.com/client/info' #批量获取客户的审核信息
	# GET_QUALITIFIED_URL = 'http://opentest.adx.qq.com/client/quali'	#获取审核通过客户的信息
	# REPORT_FORM_URL = 'http://opentest.adx.qq.com/order/report'#获取腾讯一个时间段内的数据报表

	# #广告位信息同步------------下载广告位信息
	# def load_ad_from_adx(date=nil)
	# 	url = AD_LIST_URL
	# 	params = {
	# 		"dsp_id" => DSP_ID,
	# 		"token"=>TOKEN,
	# 		"date"=> (date.nil? ? '' : date)
	# 	}
	# 	result = post(url,params)
	# 	return result
	# end

	# def post(url,params)
	# 	url = URI(url)
	# 	# http = Net::HTTP.new(url.host,url.port)
	# 	# request = Net::HTTP::Post.new(http.request_uri)
	# 	# request.body = params.to_json
	# 	# response = http.request(request)
	# 	# result = response.body
	# 	result = Net::HTTP.post_form(url,params)
	# 	result = ActiveSupport::JSON.decode(result.body)
	# 	if result["ret_code"].to_i!=0
	# 		raise "请求错误：#{result}"
	# 	end
	# 	return result
	# end


	#客户信息同步----------批量上传客户信息
	# def upload_customer_info_confirm(client_info)
	# 	url = UPLOAD_CUSTOMER_INFO_URL
	# 	params = {
	# 		"dsp_id"=>DSP_ID,
	# 		"token"=>TOKEN,
	# 		"client_info"=>client_info||[]
	# 	}
	# 	result = post(url,params)
	# 	return result
	# end

	#批量获取客户审核信息
	# names = [{'names':'浩趣互动'}.to_json]
	# result = TencentAdList.new.get_customer_status(names)
	 # => {"ret_code"=>0, "ret_msg"=>{"浩趣互动"=>{"verify_status"=>"待通过", "audit_info"=>"", "is_black"=>"N", "type"=>"ADX", "vocation"=>"", "vocation_all"=>""}}, "error_code"=>0}
	# def get_customer_status(names)
	# 	url =  GET_CUSTOMER_STATUS_URL
	# 	params={
	# 		"dsp_id"=>DSP_ID,
	# 		"token"=>TOKEN,
	# 		"names"=>names||[]
	# 	}
	# 	p params
	# 	result = post(url,params)
	# 	return result
	# end

	#获取审核通过客户的信息
	# def get_customer_qualitied
	# 	url = GET_QUALITIFIED_URL
	# 	params = {
	# 		"dsp_id"=>DSP_ID,
	# 		"token"=>TOKEN,
	# 	}
	# 	result = post(url,params)
	# 	return result
	# end

	# #腾讯报表  --用于定时任务调取
	# def get_tencent_report_form(start_date,end_date)
	# 	url = REPORT_FORM_URL
	# 	#由于start_date 跟end_date之间的差值超过7腾讯会直接报错，所以这地方判断一下，超过7就直接退出不去请求
	# 	s= Date.parse(start_date)-Date.parse(end_date)
	# 	if !s.nil? && s.to_i>7
	# 		raise '请求下载报表数据不能超过一周'
	# 	end
	# 	params = {
	# 		"dsp_id"=>DSP_ID,
	# 		"token"=>TOKEN,
	# 		"start_date"=>start_date,
	# 		"end_date"=>end_date
	# 	}
	# 	result = post(url,params)
	# 	if result["ret_code"].to_i != 0
	# 		raise "请求错误 #{result}"
	# 	end
	# 	return result
	# end
end
