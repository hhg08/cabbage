#!/usr/bin/env ruby
# encoding: utf-8
require 'yaml'
require 'json'
require "rubygems"
require "bunny"
require 'active_record'
require File.expand_path('../environment', __FILE__)
require_relative "../app/models/tencent_ad_list.rb"
SETTING = YAML::load(File.read(File.expand_path('../rabbitmq.yml', __FILE__)))
# puts SETTING["connection"]
# puts Rails.env
conn = Bunny.new(SETTING["connection"]["production"].symbolize_keys).tap(&:start)
# #工作队列模式
ch1 = conn.create_channel
q1 = ch1.queue("start_upload_originality", durable:true)
q1.subscribe(:ack=>true,block:true) do |delivery_info,metadata,payload|
	payload = JSON.parse(payload)
	id = payload["oid"]
	platform = payload["platform"]
	if (!id.nil? && (platform =="tencent"))
		result = ::TencentAdList.upload_sigle_originality(id)
	end
	if (!id.nil? && (platform =="iqiyi"))
		result = ::AiQiYiUpload.upload_iqiyi_sigle_originality(id)
	end
	ch1.ack(delivery_info.delivery_tag)
	# delivery_info.consumer.cancel#接受一次消息就取消监听
end
