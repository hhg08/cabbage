#encoding:utf-8
require 'net/http'
require 'socket'
require 'digest'
require 'time'
class DspTaskApi

	#提供一个URL,访问这个url之后可以传文件到优酷
	#将视频素材上传到优酷
	#--------配置文件变量开始
	# DSP_TOKEN_YOUKU = 'e4c1a60142d2488aa168eb7e74f19456'
	# DSP_ID_YOUKU = 11166
	# YOUKU_API_STATUS = 'http://miaozhen.atm.youku.com/dsp/api/status'
	# DSP_UPLOAD = 'http://miaozhen.atm.youku.com/dsp/api/upload'

	# CLIENT_ID = '367e496b1ea3a717'
	# CLIENT_SECRET = 'ffdc8f076ad603c574f9f38a30e38b0d'
	# ACCESS_TOKEN = 'c71beb52cab1655cdbb769667cd4a6b4'
	# REFRESH_TOKEN = 'e78768419f0c0dd02a9a1b284f51ecc7'
	#--------配置文件变量结束
	
	# client_id = '367e496b1ea3a717'
	# client_secret = 'ffdc8f076ad603c574f9f38a30e38b0d'
	# youkuUpload = YoukuUploader.new(client_id,client_secret)
	# access_token = 'c71beb52cab1655cdbb769667cd4a6b4'
	# refresh_token = 'e78768419f0c0dd02a9a1b284f51ecc7'
	#test
	# DSP_TOKEN_YOUKU = '1b070a4bfce948b7a42b6ca0a7dabfcb'
	# DSP_ID_YOUKU = 11187
	# YOUKU_API_STATUS = 'http://dsp.sandbox.yes.youku.com/dsp/api/status'
	# DSP_UPLOAD = 'http://dsp.sandbox.yes.youku.com/dsp/api/upload'
	def updateOrigin(id,data)
		originality = Originality.where('id'=>id).first
		originality.update_attributes(data)
	end

	#0 没有被youku使用 1正在提交中 2提交完成 3提交审核中 4提交审核完成，等待审核 5审核通过 6审核不通过
	#定时(1)上传文件
	def youku_file_upload
		#获取所有未被youku使用的素材
		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=0 group by r_originality_id"
		# sql_results = ActiveRecord::Base.connection.execute(sql)
		conn = ActiveRecord::Base.connection_pool.checkout
		results = conn.select_all(sql).to_hash
		results.each do |result|
			data = {}
			data["status_youku"] = 1
			updateOrigin(result["oid"],data)

			id = upload_file_to_youku(result["oname"], result["source"])
			# id = 'XMTMyMTU0MDQwMA=='
			data1 = {}
			data1["url_youku"] = "http://v.youku.com/v_show/id_#{id}.html"
			data1["status_youku"] = 2
			updateOrigin(result["oid"], data1)
		end
	end
	
	#将上传好的视频提交到优酷去审核
	#定时(2)检查上传文件的状态并更新本地数据库

	def upload_review
		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=2 group by r_originality_id"
		# sql_results = ExpandAd.find_by_sql(sql)
		conn = ActiveRecord::Base.connection_pool.checkout
		# sql_results = ActiveRecord::Base.connection.execute(sql)
		results = conn.select_all(sql).to_hash
		results.each do |result|
			#每一个提交完成的expand_ad进行状态获取
			data = {}
			data1 = {}
			data["status_youku"] = 3
			#更新originality的优酷状体为3
			updateOrigin(result["oid"], data)

			startdate = Time.at(result["ad_start"]).strftime("%Y-%m-%d")
			enddate = Time.at(result["ad_end"]).strftime("%Y-%m-%d")
			landingpage = result["target_url"]
			#在helper的application文件的公共方法
			monitor = []
			monitor << getTrackingUrl(result["aid"],result["r_originality_id"])
			isOk = upLoadReview1(result["url_youku"], startdate,enddate,landingpage,monitor)
			if isOk
				data1["status_youku"] = 4
			else		
				data1["status_youku"] = 2
			end	
			updateOrigin(result["oid"],data1)
			p "提交审核完成：#{result["url_youku"]}"
		end
	end
	#用于上面同名方法的调用，参数不同
	def upLoadReview1(youkuUrl, startdate,enddate,landingpage,monitor=[])
		#提交信息构造
		# url = 'http://miaozhen.atm.youku.com/dsp/api/upload'
		url = DSP_UPLOAD
		parameters = {}
		material = {}

		parameters["dspid"] = DSP_ID_YOUKU
		parameters["token"] = DSP_TOKEN_YOUKU

		material['url'] = youkuUrl
		material['landingpage'] = landingpage
		material['advertiser'] = '浩趣互动'
		material['startdate'] = startdate
		material['enddate'] = enddate
		material['monitor'] = monitor
		temp =[]
		temp<<material
		parameters["material"] = temp

		#发送请求 
		puts "调用/upload接口"
		result = send_data(url,parameters)
		p result
		if result["result"].to_i!= 0
			raise "执行上传信息不成功"
		end
		temp_url = []
		temp_url<< youkuUrl
		puts "调用/status接口查看审核状态"
		sb = get_file_status(temp_url)
		records = sb["message"]["records"] if !sb.nil?	
		puts "查看返回记录"
		puts sb["message"]["records"]
		records&&records.each do |record|
			result = record["result"]
			if result == '待审核'
				return true
			else
				return false
			end
		end
		return false
	end

	# materialurl = 'http://v.youku.com/v_show/id_XMTMzODAyMzE5Ng==.html?from=y1.7-2'
	# DspTaskApi.new.get_file_status(materialurl)
	#，用于上面文件，获取文件审核状态
	def get_file_status(materialurl=[])
		puts "查询的素材"
		puts materialurl
		url = YOUKU_API_STATUS
		parameters = {}
		parameters["dspid"] = DSP_ID_YOUKU
		parameters["token"] = DSP_TOKEN_YOUKU
		parameters['materialurl'] = materialurl

		result = send_data(url, parameters)#可对结果进行某些操作
		result = ActiveSupport::JSON.decode(result)
		puts "查询结果"
		puts result
		return result
	end


	#定时(3)获取文件审核信息，更新本地数据库
	def youku_status_check
		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=4 group by r_originality_id"
		conn = ActiveRecord::Base.connection_pool.checkout
		results = conn.select_all(sql).to_hash
		urlAry = []
		idUrl = {} 
		results.each do |result|
			p result["url_youku"]
			p result["aid"]
			id_hash = {result["url_youku"]=> result["aid"]}
			idUrl.merge!(id_hash)
			urlAry.push(result["url_youku"])
		end
		return if urlAry.empty?
		result = get_file_status(urlAry)
		records = result["message"]["records"] if result
		# result1 = []
		if !records.nil?
			records.each do |record|
				conditionAD={'id'=>idUrl[record["url"]]}
				result = record["result"]
				data = {}
				data_ad = {}
				case record["result"]
				when '不通过'
					data["status_youku"] = 6
					data["reason_youku"] = record["reason"]
					data_ad["checkstatus"] = 2
				when '通过'
					data["status_youku"] = 5
					data["reason_youku"] = record["reason"]
					data_ad["checkstatus"] = 1
				when '待审核'
					data["status_youku"] = 4
					data["reason_youku"] = record["reason"]
					data_ad["checkstatus"] = 0
				end
				condition={'url_youku'=>record["url"]}
				originality = Originality.where(condition).first
				originality.update_attributes(data) if originality
				expand_ad = ExpandAd.where(conditionAD).first
				expand_ad.update_attributes(data_ad) if expand_ad
			end
		end
		result  #是不是数组形式
	end

	#定时4 
	def replenish
		sql = "select * from hq_report where group_id = 0"		
		conn = ActiveRecord::Base.connection_pool.checkout
		results = conn.select_all(sql).to_hash
		results.each do |result|
			expand_ad = ExpandAd.find(result["ad_id"])
			gid = expand_ad['plan']
			report = Report.find(result["id"])
			report.update_attributes({"group_id"=>gid}) if report
		end
		c = results.count
		p "更新完成，共#{c}个"
	end

	#对接优酷接口APIpost请求
	def send_data(url, data)
		url = URI.parse(url)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url.request_uri)
		request.body = data.to_json
		response = http.request(request)
		result =  response.body
		return result
	end

	#用于文件定时上传方法调用，构造上传的基本信息
	# dsp = DspTaskApi.new
	# dsp.upload_file_to_youku('ruby_test','./Public/2015-07-15-test1_vovo.flv')
	def upload_file_to_youku(title,videoPath)
	# def upload_file_to_youku(title,videoPath='./Public/2015-07-15-test1_vovo.flv')
		#获取token阶段
		videoPath =  CREATIVE_PATH +　souce
		client_id = CLIENT_ID
		client_secret = CLIENT_SECRET
		youkuUpload = YoukuUploader.new(client_id,client_secret)
		access_token = ACCESS_TOKEN
		refresh_token = REFRESH_TOKEN

		params =  {'access_token' => access_token , 'refresh_token' => refresh_token}
		file_name = videoPath

		begin
			file_md5 = Digest::MD5.new.update(File.open(file_name,"r").read).to_s
			if !file_md5
				return 
			end
			file_size = File.size(file_name)
			upload_info = {}
			upload_info["title"] = title
			upload_info["tags"] = title
			upload_info["file_name"] = file_name
			upload_info["file_md5"] = file_md5
			upload_info["file_size"] = file_size
			progress = true

			commit_result = youkuUpload.upload(progress,params,upload_info)
			return commit_result["video_id"]
		rescue Exception => e
			raise e
		end
	end

	def getTrackingUrl(hqAdId,hqCreativeId,hqSource='youku',hqEvent=1)
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
