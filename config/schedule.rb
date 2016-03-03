# -*- encoding : utf-8 -*-

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
# set :output, "/alidata1/web/yuying/log/whenever.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#每一分钟运行一次
every 1.minutes do
# every 1.seconds do
	#定时上传文件
	runner "DspTaskApi.youku_file_upload"
	#定时检查文件审核状态
	runner "DspTaskApi.uploadReview"
	#定时获取文件审核状态
	runner "DspTaskApi.youkuStatusCheck"
	# puts "----------------every.seconds"
end
