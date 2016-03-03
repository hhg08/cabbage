#encoding:utf-8
require 'net/http'
class AccountSet < ActiveRecord::Base
	def set_account(attrs)
		mapping_url = attrs[:mapping_url]
		bid_url = attrs[:bid_url]
		win_notice_url = attrs[:win_notice_url]
		qps = attrs[:qps]
		no_cm_response = attrs[:no_cm_response]
		use_tuserinfo = attrs[:use_tuserinfo]
		rtb_msg_format = attrs[:rtb_msg_format]

		#修改mapping_url
		result = DSP::API::Account.set_mapping_url(mapping_url)
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		result = DSP::API::Account.set_bid_url(bid_url)
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		result = DSP::API::Account.set_win_notice_url(win_notice_url)
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		result = DSP::API::Account.set_qps(qps)
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		result = DSP::API::Account.set_no_cm_response(no_cm_response)
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		result = DSP::API::Account.set_use_tuserinfo(use_tuserinfo)
		#如果执行成功 ret_code==0  1代表全部执行失败，2代表部分成功，部分失败，3系统认证失败或内部错误
		if result["ret_code"].to_i != 0
			raise "请求错误，请确认"
		end

		dsp_id = DSP::AUTH[:dsp_id]
		params = {
			"dsp_id" => dsp_id||'',
			"mapping_url" => mapping_url||'',
			"bid_url" => bid_url||'',
			"win_notice_url" => win_notice_url||'',
			"qps" => qps||'',
			"no_cm_response" => no_cm_response||true,
			"use_tuserinfo" => use_tuserinfo||false,#由于该属性官方关闭只能为false
			"rtb_msg_format" => rtb_msg_format||'',
		}
		account = AccountSet.where("dsp_id"=>dsp_id.to_i).first
		if account
			account.update_attributes(params)
		else
			account = AccountSet.new(params)
			account.save
		end
	end



	#------------------------------------------分割线

	# attr_accessible :mapping_url, :bid_url, :win_notice_url, :qps, :no_cm_response, :rtb_msg_format, :use_tuserinfo
	# DSP_ID = '190'
	# TOKEN = '73553e669b7270a4934706f76a99ad36'
	# ACCOUNT_SET_URL = 'http://opentest.adx.qq.com/config/set'
	#test
	#attrs={mapping_url:'http://jingyan.baidu.com/article/c843ea0b6cf64277931e4a1b.html',bid_url:'http://jingyan.baidu.com/article/c843a0b6cf64277931e4a1b.html',win_notice_url:'http://jingyan.baidu.com/article/c843ea0b6cf64277931e4a1b.html',qps:23,no_cm_response: 'Y',use_tuserinfo:'Y',rtb_msg_format:'json'}
	#acount = AccountSet.new.set_account(attrs)
	# def set_account(attrs)
	# 	token = {"token" => TOKEN}
	# 	params = {
	# 		"dsp_id" => DSP_ID,
	# 		"mapping_url" => attrs["mapping_url"]||attrs[:mapping_url],
	# 		"bid_url" => attrs["bid_url"]||attrs[:bid_url],
	# 		"win_notice_url" => attrs["win_notice_url"]||attrs[:win_notice_url],
	# 		"qps" => attrs["qps"]||attrs[:qps],
	# 		"no_cm_response" => attrs["no_cm_response"]||attrs[:no_cm_response],
	# 		"use_tuserinfo" => attrs["use_tuserinfo"]||attrs[:use_tuserinfo],
	# 		"rtb_msg_format" => attrs["rtb_msg_format"]||attrs[:rtb_msg_format],
	# 	}
	# 	url = URI(ACCOUNT_SET_URL)
	# 	# http = Net::HTTP.new(url.host,url.port)
	# 	# request = Net::HTTP::Post.new(url.request_uri)
	# 	# request.body = params.to_json
	# 	# response = http.request(request)
	# 	response = Net::HTTP.post_form(url,params.merge(token))
	# 	result = response.body
	# 	#如果执行成功 ret_code==0  1代表全部执行失败，2代表部分成功，部分失败，3系统认证失败或内部错误
	# 	if result["ret_code"].to_i != 0
	# 		raise "请求错误，请确认"
	# 	end
	# 	account = AccountSet.where("dsp_id"=>DSP_ID).first
	# 	if account
	# 		account.update_attributes(params)
	# 	else
	# 		account = AccountSet.new(params)
	# 		account.save
	# 	end
	# end
end
