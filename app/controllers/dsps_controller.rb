# #encoding:utf-8
# class DspsController < ApplicationController
# 	#提供一个URL,访问这个url之后可以传文件到优酷
# 	#将视频素材上传到优酷
	
# 	def updateOrigin(id,data)
# 		originality = Originality.where('id'=>id).first
# 		originality.update_attributes(data)
# 	end
# 	#0 没有被youku使用 1正在提交中 2提交完成 3提交审核中 4提交审核完成，等待审核 5审核通过 6审核不通过
# 	def youku_file_upload
# 		#获取所有未被youku使用的素材
# 		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=0 group by r_originality_id"
# 		sql_results = ExpandAd.find_by_sql(sql)
# 		sql_results.each do |sql_result|
# 			#调用上传方法，获取commit之后的结果，作为id
# 			data = {}
# 			data["status_youku"] = 1
# 			originality = Originality.where('id'=>sql_result["oid"]).first
# 			originality.update_attributes(data)

# 			id = upload_file_to_youku(sql_result["oname"], sql_result["source"])
# 			data["url_youku"] = 'http://v.youku.com/v_show/id_'+id+'.html'
# 			originality = Originality.where('id'=>sql_result["oid"]).first
# 			data["status_youku"] = 2
# 			originality.update_attributes(data)
# 		end
# 	end
# 	#提交审核
# 	def upload_review
# 		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=2 group by r_originality_id"
# 		sql_results = ExpandAd.find_by_sql(sql)
# 		sql_results.each do |sql_result|
# 			#每一个提交完成的expand_ad进行状态获取
# 			data = {}
# 			data["status_youku"] = 3
# 			#更新originality的优酷状体为3
# 			Originality.update_attributes(data)
# 			#提交信息构造
# 			url = 'http://miaozhen.atm.youku.com/dsp/api/upload'
# 			data = {}
# 			material = {}

# 			data["dspid"] = 11166
# 			data["token"] = 'e4c1a60142d2488aa168eb7e74f19456'

# 			material['url'] = sql_result["youkuUrl"];
# 			material['landingpage'] = sql_result["landingpage"];
# 			material['advertiser'] = '浩趣互动';
# 			material['startdate'] = sql_result["startdate"];
# 			material['enddate'] = sql_result["enddate"];
# 			material['monitor'] = sql_result["monitor"]||[]
# 			data["material"] = material;

# 			#发送请求
# 			result = send_date(url,data)	
# 			# puts res.body
# 			if result["result"].to_i == 0
# 				data["status_youku"] = 2
# 			else
# 				data["status_youku"] = 4
# 			end
# 			Originality.update_attributes(data)
# 		end
# 	end
# 	#获取文件审核状态
# 	def get_file_status
# 		sql = "select *,hq_expand_ad.id as aid,hq_originality.id as oid,hq_originality.id as oname from hq_expand_ad_originality left join hq_originality on hq_expand_ad_originality.`r_originality_id`=hq_originality.id left join hq_expand_ad on hq_expand_ad_originality.`r_ad_id`=hq_expand_ad.id where source_type='video' AND plantform_youku=1 AND status_youku=4 group by r_originality_id"
# 		sql_query = ActiveRecord::Base.find_by_sql(sql)
# 		materialurl = sql_query.map { |re| re["url_youku"]}

# 		url = 'http://miaozhen.atm.youku.com/dsp/api/status'
# 		data = {}
# 		data["dspid"] = 11166
# 		data["token"] = 'e4c1a60142d2488aa168eb7e74f19456'
# 		data['materialurl'] = materialurl;#要查询素材的url数组
# 		result = send_date(url, data)#可对结果进行某些操作
		
# 		records = result["message"]["records"]
# 		records.each do |record|
# 			data = {}
# 			data_ad = {}
# 			case record["result"]
# 			when '不通过'
# 				data["status_youku"] = 6
# 				data["reason_youku"] = record["reason"]
# 				data_ad["checkstatus"] = 2
# 			when '通过'
# 				data["status_youku"] = 5
# 				data["reason_youku"] = record["reason"]
# 				data_ad["checkstatus"] = 1
# 			when '待审核'
# 				data["status_youku"] = 4
# 				data["reason_youku"] = record["reason"]
# 				data_ad["checkstatus"] = 0
# 			end
# 			originality = Originality.where('originality' => record["url"]).first
# 			originality.update_attributes(data)
# 			expand_ad = ExpandAd.where('originality' => record['url']).first
# 			expand_ad.update_attributes(data_ad)
# 		end
# 		result
# 	end

# 	def send_date(url, data)
# 		uri = URI(url)
# 		res = Net::HTTP.post_form(uri, data)

# 		# require 'net/http'
 
# 		# url = URI.parse('http://www.rubyinside.com/test.cgi')
		 
# 		# Net::HTTP.start(url.host, url.port) do |http|
# 		#   req = Net::HTTP::Post.new(url.path)
# 		#   req.set_form_data({ 'name' => 'David', 'age' => '24' })
# 		#   puts http.request(req).body
# 		# end
# 	end
	
# 	def upload_file_to_youku(title,videoPath="Public/materials/2015-07-15-test1_vovo.flv")
# 		#获取token阶段
# 		client_id = 'a06261b34d59133b'
# 		client_secret = '479aaa53bd6090d1d181f9c519704df7'
# 		access_token = ''#？
# 		params["access_token"] = access_token["access_token"]
# 		file_name = videoPath

# 		upload_info = []#这个数组的结构形式是什么{}

# 		progress = true

# 		commit_result = upload(progress,params,upload_info)
# 		return commit_result["video_id"]
# 	end

# 	def upload(upload_process=true,params={},upload_info={})
# 		if params["access_token"] && !params["access_token"].empty?
# 			access_token = params["access_token"]
# 			if params["refresh_token"] && !params["refresh_token"].empty?
# 				refresh_token = params["refresh_token"]
# 				read_fresh_file(REFRESH_FILE)
# 			end
# 		else
# 			result = get_access_token(params)
# 			if !result.nil?
# 				access_token = result["access_token"]
# 			end
# 		end
# 		version_update('./Public/verlog.txt')
# 		upload_result = get_upload_token(upload_info)
# 		if upload_result&&upload_result["error"] && upload_result["error"]["code"] = '1009' && !upload_result["refresh_token"].empty?
# 			refresh_result = refresh_token
# 			access_token = refresh_result["access_token"]
# 			refresh_token = refresh_info["refresh_token"]
# 			write_refresh_file =
# 		end
# 	end

# 	def get_upload_token(upload_info)
# 		# begin
# 		# 	basic = {
# 		# 		'client_id' = 
# 		# 		'access_token' = 
# 		# 	}
# 		# 	params = basic.merge(upload_info)
# 		# 	uri = URI.parse("https://openapi.youku.com/v2/uploads/create.json")
# 		# 	uri.query = URI.encode_www_form(params)
# 		# 	res = Net::HTTP.get_response(uri)
# 		# 	return res.body
# 		# rescue Exception => e
# 		# 	raise 
# 		# end
# 	end

# 	def refresh_token
# 		# parameter = {
# 		# 	'client_id'=>
# 		# 	'client_secret'=>
# 		# 	'grant_type' => 'refresh_token'
# 		# 	'refresh_token' => refresh_token
# 		# }
# 		# uri = "https://openapi.youku.com/v2/oauth2/token"
# 		# url = URI.parse(uri)
# 		# res = send_date(url,parameter)
# 		# return res.body
# 	end

# 	def read_refresh_file(refresh_file)
# 		#获取整个文件的信息
# 		file = File.open(refresh_file,'r')
# 		file.each do ||
# 			refresh_info = 
# 		end
# 	end
# end
