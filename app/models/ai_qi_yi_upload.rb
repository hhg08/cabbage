#encoding:utf-8
require 'net/http'
require 'httparty'
require 'json'
require 'bunny'
require 'cgi'
require 'date'
require 'pathname'
class AiQiYiUpload < ActiveRecord::Base
	DSP_TOKEN = '5f7673c68a5a819379a73b177c89b23a'
	UPLOAD_ORIGINA_POST_URL = 'http://220.181.184.220/upload/post'
	CHECK_ORIGIN_STATUS_URL = 'http://220.181.184.220/upload/api/query'
	UPLOAD_ADVER_POST_URL = 'http://220.181.184.220/upload/advertiser'
	CHECK_ADVER_STATUS_URL = 'http://220.181.184.220/upload/api/advertiser'
	PLANTFORM = {"PC"=>"1","Mobile"=>"2","Tablet"=>"2","Mobile_Tablet"=>"2"}
	SETTING_RABBIT = YAML::load(File.read(File.expand_path('../../../config/rabbitmq.yml', __FILE__)))
	#0 没有被iqiyi使用 1正在提交中 2提交完成 3提交审核中 4提交审核完成，等待审核 5审核通过 6审核不通过
	class << self
		def aiqiyi_ad_material_upload
			sql = "select *, o.id as oid,o.id as oname,e.id as eid,`guige`,`source_type`,`source`,`source_yun` FROM hq_originality o LEFT JOIN (select * from hq_originality_exchange where plantform='iqiyi') e on o.id=e.originality_id WHERE `is_del` = 0 AND `status` = 0 AND `source_type` IN ('video','image','flash')"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			ids = results.map { |e| e["oid"]}
			ids.each do |id|
				upload_iqiyi_sigle_originality id
			end
		end
		def upload_iqiyi_sigle_originality id
			originality = Originality.find id
			unless originality.nil?
				return if originality["ad_type"].nil?
				return if originality["platform"].nil?#注意下这里有个字段有n与没有n的区别
				com_quli_id = originality["company"]
				company = Company.find(com_quli_id)
				if company
					com_qulity = CompanyQuality.where("company"=>com_quli_id).first
					p com_qulity
					return  if com_qulity.status.to_i != 4#广告主审核未通过不让上传广告
					if Rails.env.to_s == "production"
						file_url="http://dsp.hogic.cn/"+originality["source"]
						url = "http://dsp.hogic.cn/"+originality["source"]+'#'+originality["id"].to_s
					else
						file_url="http://dev.dsp.hogic.cn/"+originality["source"]
						url = "http://dev.dsp.hogic.cn/"+originality["source"]+'#'+originality["id"].to_s
					end
					uri = URI.parse(file_url)
					res = Net::HTTP.get_response(uri)
					return if res.code.to_s != "200"
					file_data = res.body
					hqAdId = originality["id"]
					ad_type = originality["ad_type"]#1为贴片创意，2为暂停创意，3为云交互贴片，4为角标（只支持移动端）,9为overlay，默认为1
					ad_id = originality["company"]
					file_suffix = Pathname.new(originality["source"]).extname#originality["source"].split('.')[1]
					file_name = CGI.escape("#{originality["name"]}.#{file_suffix}")
					plantform = originality["platform"]#PLANTFORM["#{originality["i_platform"]}"]||'1'#默认为PC平台
					y = (Date.today.strftime("%Y").to_i + 1).to_s
					m = Date.today.strftime("%m").to_s
					d = Date.today.strftime("%d").to_s
					end_date = y+m+d
					headers = {
						"dsp_token" => "#{DSP_TOKEN}",
						"click_url" => "#{originality["target_url"]}",
						"ad_id" => "#{ad_id}",#测试的时候需要屏蔽
						"video_id" => "#{hqAdId}",
						"ad_type" => "#{ad_type}",
						"file_name" => file_name,
						"platform" => "#{plantform}",#1pc，2移动
						"duration" => "#{originality["video_time"]}",
						"dpi" => "#{originality["guige"]}",
						"end_date"=>end_date,
						"content-type"=>"application/octet-stream"
					}
					p headers
					result_res = HTTParty.post(UPLOAD_ORIGINA_POST_URL,body:file_data,headers:headers,timeout:600)
					result1 = JSON.parse(result_res.body)
					p result1

					if (result1["code"].to_i == 0)&& !result1["m_id"].nil?
						originality_exchange = OriginalityExchange.where("originality_id"=>originality["id"],"plantform"=>"iqiyi").first
						if originality_exchange
							originality_exchange.update_attributes({"status"=>4,"url"=>url, "m_id"=>result1["m_id"],"originality_id"=>originality["id"]})
						else
							OriginalityExchange.create({"plantform"=>'iqiyi',"status"=>4,"url"=>url, "m_id"=>result1["m_id"],"originality_id"=>originality["id"]})
						end
					end
				end
			end
		end

		#0待提交 1正在提交中 2提交完成 3提交审核中 4提交审核完成，等待审核 5审核通过 6审核不通过 7无需提交
		#广告的checkstatus'审核中', '审核通过', '未审核通过', '无需审核'，0 1 2,3
		#定时更新iqiyi上传素材的状态
		def check_aiqiyi_status
			sql = "select *, o.id as oid,o.id as oname,e.id as eid,`guige`,`source_type`,`source`,`source_yun` FROM hq_originality o LEFT JOIN (select * from hq_originality_exchange where plantform='iqiyi') e on o.id=e.originality_id WHERE `is_del` = 0 AND (status=4 OR status=6) AND `source_type` IN ('video','image','flash')"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			ids = results.map { |e| e["oid"]}
			messages = []
			ids.each do |id|
				originality_status=check_single_originality_status id
				puts originality_status
				if originality_status[:flag]
					messages << originality_status[:info]
				end
			end
			publish_originality_messages(messages.to_json) if !messages.empty?
		end
		def check_single_originality_status(id)
			originality = Originality.find(id)
			originality_exchange = OriginalityExchange.where("originality_id"=>originality["id"],"plantform"=>"iqiyi").first
			if originality&&originality_exchange
				uri = URI.parse(CHECK_ORIGIN_STATUS_URL)
				params = {
					dsp_token:DSP_TOKEN,
					m_id:originality_exchange["m_id"],
				}
				uri.query = URI.encode_www_form(params)
				res = Net::HTTP.get_response(uri)
				record = JSON.parse(res.body)
				p record
				unless record["status"].nil?
					data_ad = {}
					status = 0
					case record["status"]
					when "INIT"
						#上传成功，处理中
						update_originality_exchange(originality["id"],{"status"=>2})
						# data_ad["checkstatus"] = 2
					when "AUDIT_UNPASS"
						update_originality_exchange(originality["id"],{"status"=>6,"reason"=>record["reason"]})
						status = 2
						# data_ad["checkstatus"] = 2
					when "COMPLETE"
						update_originality_exchange(originality["id"],{"status"=>5,"reason"=>"审核通过", "p_crid"=>record["tv_id"]})
						status = 1
						# data_ad["checkstatus"] = 1
					when "AUDIT_WAIT"
						update_originality_exchange(originality["id"],{"status"=>4,"reason"=>"待审核"})
						# data_ad["checkstatus"] = 0
					when "OFF"
						update_originality_exchange(originality["id"],{"status"=>6,"reason"=>record["reason"]})
						status = 2
						# data_ad["checkstatus"] = 2
					end
					if ["AUDIT_UNPASS","COMPLETE","OFF"].include? record["status"]
						return {flag:true,info:{oid:originality["id"],status:status,plantform:"iqiyi"}}
					end
				end
			end
			return {flag:false}
		end

		#上传广告主信息
		def upload_advertiser_info
			#0新添加,1已修改,2提交完成,待审核，3审核不通过,4审核通过
			sql = "select *, hq_company_quality.id as qual_id, hq_company.id as comp_id from hq_company left join hq_company_quality on hq_company.id = hq_company_quality.company where status=0 or status=1 group by comp_id"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			results.each do |result|
				op = (result["status"].to_i==1)? "update" : "create"
				file_suffix = result["file_name"].split('.')[1]
				if Rails.env.to_s == "production"
					file_url="http://dsp.hogic.cn"+result["file_name"]
				else
					file_url="http://dev.dsp.hogic.cn"+result["file_name"]#测试环境增加dev前缀
				end
				uri = URI.parse(file_url)
				res = Net::HTTP.get_response(uri)
				next if res.code.to_s != "200"
				file_data = res.body
				name = CGI.escape("#{result["name"]}")
				industry = CGI.escape("#{result["industry"]}")
				file_name = CGI.escape("#{result["name"]}.#{file_suffix}")
				headers = {
					"dsp_token"=>"#{DSP_TOKEN}",
					"ad_id"=>"#{result["comp_id"]}",
					"name"=>name,
					"industry"=>industry,
					"op"=>"#{op}",
					"file_name"=>file_name,
					"content-type"=>"application/octet-stream"
				}
				p headers
				res = HTTParty.post(UPLOAD_ADVER_POST_URL,body:file_data,headers:headers)
				res_hash = JSON.parse(res.body)
				p res_hash
				if res_hash["code"].to_i == 0
					update_company_status(result["qual_id"],{status:2})
				end
			end
		end

		#广告主信息查询
		def check_adver_status
			#0新添加,1已修改,2提交完成,待审核,3审核不通过,4审核通过
			sql = "select *, hq_company_quality.id as qual_id, hq_company.id as comp_id from hq_company left join hq_company_quality on hq_company.id = hq_company_quality.company where status=2 group by comp_id"
			conn = ActiveRecord::Base.connection_pool.checkout
			results = conn.select_all(sql).to_hash
			results.each do |result|
				uri = URI(CHECK_ADVER_STATUS_URL)
				params={
					"dsp_token"=>DSP_TOKEN,
					"ad_id" =>result["comp_id"].to_i
				}
				uri.query = URI.encode_www_form(params)
				res = Net::HTTP.get_response(uri)
				record = JSON.parse(res.body)
				p record
				unless record["status"].nil?
					data_ad = {}
					case record["status"]
					when "UNPASS"
						update_company_status(result["qual_id"],{"status"=>3,"reason"=>record["reason"]})
					when "PASS"
						update_company_status(result["qual_id"],{"status"=>4,"reason"=>"审核通过"})
					when "WAIT"
						update_company_status(result["qual_id"],{"status"=>2,"reason"=>"待审核"})
					end
				end
			end
		end

		def publish_originality_messages(messages)
			if Rails.env.to_s == "production"
				conn = Bunny.new(SETTING_RABBIT["connection"]["production"].symbolize_keys).tap(&:start)
			else
				conn = Bunny.new(SETTING_RABBIT["connection"]["development"].symbolize_keys).tap(&:start)
			end
			conn.start
			ch = conn.create_channel
			q = ch.queue("task_update_originality_status",durable:true)
			q.publish(messages,persistent:true)
			conn.close
		end

		#更新素材状态
		def update_originality_exchange(id,data)
			originality_exchange = OriginalityExchange.where("originality_id"=>id,"plantform"=>"iqiyi").first
			originality_exchange.update_attributes(data) if originality_exchange
		end

		#更新广告主信息
		def update_company_status(id,data)
			company = CompanyQuality.find(id)
			company.update_attributes(data) if company
		end

		#1为贴片创意，2为暂停创意，3为云交互贴片，4为角标（只支持移动端）,9为overlay，默认为1
		def guige_judgment(guige)
			case guige
			when "640x480","640x360"
				return 1
			when "425x320","950x790","428x356","422x352"
				return 2
			when "240x200","180x150"
				return 4
			when "480x70"
				return 9
			end
		end
	end







#---------------------------------------------------------------------------------------------分割线----
	# def getTrackingUrl(hqAdId,hqCreativeId,hqSource='youku',hqEvent=1)
	#     sql = "select *,hq_expand_ad.id as aid from hq_expand_ad left join hq_expand_plan on hq_expand_ad.plan=hq_expand_plan.id where hq_expand_ad.id=#{hqAdId}"
	# 	conn = ActiveRecord::Base.connection_pool.checkout
	# 	results = conn.select_all(sql).to_hash
	#     result = results[0]
	#     hqClientId = result['company']
	#     hqAdId = result['aid']
	#     hqGroupId = result['plan']
	#     # $hqCreativeId = $result['originality'];
	#      return "http://track.hogic.cn/api/ads?hqClientId=#{hqClientId}&hqGroupId=#{hqGroupId}&hqAdId=#{hqAdId}&hqCreativeId=#{hqCreativeId}&hqSource=#{hqSource}&hqEvent=#{hqEvent}"
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
end
