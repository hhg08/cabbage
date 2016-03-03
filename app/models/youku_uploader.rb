#encoding:utf-8
require 'net/http'
# require 'md5'
require 'socket'
require 'digest'
require 'zlib'
require 'rest_client'
class YoukuUploader
	#配置文件里面定义     开始
	# ACCESS_TOKEN_URL = "https://openapi.youku.com/v2/oauth2/token"
	# UPLOAD_TOKEN_URL = "https://openapi.youku.com/v2/uploads/create.json"
	# UPLOAD_COMMIT_URL = "https://openapi.youku.com/v2/uploads/commit.json"
	# VERSION_UPDATE_URL = "http://open.youku.com/sdk/version_update"
	# REFRESH_FILE = "./Public/refresh.txt"
	#配置文件里面定义     结束
	#初始化
	def initialize(client_id, client_secret)
		@client_id = client_id
		@client_secret = client_secret
		# @access_token = 'e4c1a60142d2488aa168eb7e74f19456'
		# @upload_token = ''
		# @upload_server_ip = ''
		# @refresh_token = ''
	end


	# uploader = YoukuUploader.new('367e496b1ea3a717', 'ffdc8f076ad603c574f9f38a30e38b0d')
	# title = "test ruby sdk"
	# file_name = "/Users/yuchao/Downloads/2015-07-15-test1_vovo.flv"
	# file_md5 = Digest::MD5.new.update(File.open(file_name,"r").read).to_s
	# uploadInfo = {"title" => title, "tags" => title, "file_name" => file_name,
	# "file_md5" => file_md5 , "file_size" => File.size(file_name) 	}
	# uploader.upload(true, {'access_token' => 'c71beb52cab1655cdbb769667cd4a6b4' , 'refresh_token' => 'e78768419f0c0dd02a9a1b284f51ecc7'}, uploadInfo)

	#上传方法
	def upload(upload_process = true, params = {},uploadInfo = {})

		if params["access_token"] && !params["access_token"].empty?
			@access_token = params["access_token"]
			if params["refresh_token"] && !params["refresh_token"].empty?
				@refresh_token = params["refresh_token"]
			end
			read_refresh_file(REFRESH_FILE)
		else
			#获取登陆认证阶段{client_id,client_secret,grant_type,refresh_token}  return access_token,expires_in,refresh_token,token_type
			puts "Only applys to the clients of partner level!"
			raise "TODO should implement this logic if needed"
			# result = getAccessToken(params)
			# if result
			# 	@access_token = result["access_token"]
			# end
		end 

		#== should be removed begin
		#调用版本更新方法
		# version_update('./Public/verlog.txt')
		#== should be removed end

		#根据上传信息，获取上传文件的准备信息
		#client_id,access_token,title,tags,file_name,file_md5,file_size return=>{upload_token,upload_server_uri,也有错误码}
		uploadResult = get_upload_token(uploadInfo)#会调用/create.json

		if (uploadResult["error"] && uploadResult['error']['code'].to_i == 1009)
			# TODO should refresh token automatically
			raise "please use valid access token & refresh token"
		end

		# if (uploadResult["error"] && uploadResult['error']['code'].to_i == 1009 && !@refresh_token.empty?)
		# 	refreshResult = refreshToken#method
    #
		# 	@access_token = refreshResult["access_token"]
		# 	@refresh_token = refreshInfo['refresh_token']
		# 	writeRefreshFile(REFRESH_FILE, refreshResult)
		# 	uploadResult = getUploadToken(uploadInfo)
		# end


		if !uploadResult['upload_token']
			raise "create upload token failed"
		end

		@upload_token = uploadResult["upload_token"]
		file_name = uploadInfo['file_name']
		
		@upload_server_ip = TCPSocket.gethostbyname(uploadResult['upload_server_uri']).last#返回一个数组，最后一个值为ip
		#调用/create_file.json
		#{upload_token,file_size, ext(文件扩展名) return=>{error,code,type,description}}
		uploadCreate = upload_create(file_name)

		puts "Uploading start!"
		finish = false
		transferred = 0	
		#调用/....../gupload/new_slice 获取第一个分片的任务ID，视屏源文件中开始位置，大小
		#{upload_token}  return=>{slice_task_id,offset,length,transfered,finished}
		sliceResult = create_slice()
		slice_id = sliceResult['slice_task_id']
		offset = sliceResult['offset']
		length = sliceResult['length']
		uploadServerIp = ''
		begin
			#调用new_slice之后从返回结果获得此接口对应的各项参数，多次调用直到check过程finished字段为true
			#调用.../gupload/upload_slice   crcstring分片数据的16禁止CRC32校验，默认为null，hashstring分片数据的16进制MD5默认Note,CRC or HASH校验用于检测错误和分片重复上传
			#{upload_token,slice_task_id,offset,length  return=>{slice_task_id,offset,length,transferred,finished}}
			uploadSlice = upload_slice(slice_id,offset,length,file_name)
			slice_id = uploadSlice['slice_task_id']
			offset = uploadSlice['offset']
			length = uploadSlice['length']
			transferred = (uploadSlice['transferred'].to_f/uploadInfo['file_size'].to_f*100).round#浮点数的四舍五入取整
			if (slice_id.to_i == 0)
				while true do
					#查询视频上传过程中的状态   get调用 .../gupload/check
					#{upload_token,return=>{status={1,2,3,4}，transferred_percent,confirmed_percent,empty_tasks,finished,upload_server_ip}}
					checkResult = check
					if (checkResult['status'])
						finish = checkResult['finished']
						#文件上传完成，并全部确认写入磁盘
						if (checkResult['status'] == 1)
							uploadServerIp = checkResult['upload_server_ip']
							transferred = 100
							break
							#文件上传中，2为全部分片上传任务已经分派，3为上传任务都完成，但是依然有分片未确认写入磁盘（2,3状态换句话就是没完成整个流程需要继续check）
						elsif (checkResult['status'] == 2 || checkResult['status'] == 3)
							#服务器接受数据并写入磁盘百分比3状态有意义
							transferred = checkResult['confirmed_percent']			
						end
					end
				end
			end
			puts "Upload progress:#{transferred}%" if upload_process
		end while !finish
		if (finish)
			#commit上传最后一步  调用..../v2/uploads/commit.json
			#{access_token, client_id,upload_token,upload_server_ip, return={video_id}}
			commitResult = commit(uploadServerIp)
			puts "upload success"
			puts "videoid: #{commitResult['video_id']}" if (commitResult['video_id'])
			return commitResult
		end
	end
 
	#get方式访问	
	def get(url,params, options = {})
		url = URI(url+"?"+URI.encode_www_form(params))
		puts "GET #{url}"
		http = Net::HTTP.new(url.hostname, url.port)
		if options[:HTTPS]
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
		end
		req = Net::HTTP::Get.new(url.request_uri)
		# req.query =
		resp = http.request(req)
		puts "response #{resp.body}"
		resp.body
	end
	#post方式访问
	def post(url, data)
		uri = URI(url)
		puts "POST #{url}"
		resp = Net::HTTP.post_form(uri, data)
		puts "response #{resp.body}"
		return resp.body
	end

	def check
		url = "http://#{@upload_server_ip}/gupload/check"
		param = {'upload_token' => @upload_token}
		res =get(url,param)
		result = JSON.parse(res)
		raise result['error'] if result['error']
		result
	end
	
	# def refreshToken
   #      begin
   #      	url = ACCESS_TOKEN_URL
	# 			parameter = {
	#             "client_id"     => @client_id,
	#             "client_secret" => @client_secret,
	#             "grant_type" 	=> 'refresh_token',
	#             "refresh_token" => @refresh_token
	#         }
   #      	res =  post(url,parameter)
   #      	result = JSON.parse(res)
   #      rescue Exception => e
   #      	raise e
   #      end
	# end



	def read_refresh_file(refresh_file)
		return #TODO
		file=File.open(refresh_file,'r')
		if file
			refresh_info = JSON.parse(file.read.strip)
			@access_token = refresh_info['access_token'] || ''
			@refresh_token = refresh_info['refresh_token'] || ''
		end
		file.close
	end
	
	def writeRefreshFile(refresh_file,refresh_json_result) 
		file = File.open(refresh_file,'w')
		if !file
			p "Could not openn#{refresh_file}"
		else
			fw = file.write(refresh_json_result)
			if !fw
				p "write refresh file fail!"
			end
			file.close
		end		
	end
	
	# def getAccessToken(params={})
	# 	begin
	# 		parameter = {
	# 			"client_id"     => @client_id,
	# 			"client_secret" => @client_secret,
	# 			"grant_type" => 'password',
	# 			# "username"       => params['username'],
	# 			"username"       => '18600283835',
	# 			# "password"       => params['password'],
	# 			"password"       => 'dangtuo2008',
	# 		}
	# 		p  parameter
	# 		url = ACCESS_TOKEN_URL
	# 		res = post(url, parameter)
	# 		result = JSON.parse(res)
	# 	rescue Exception => e
	# 		raise e
	# 	end
	# end


	def get_upload_token(uploadInfo)
		begin
			basic = {
				"client_id" => @client_id,
				"access_token" => @access_token,
			}
			params = basic.merge(uploadInfo)
			url = UPLOAD_TOKEN_URL
			res = get(url, params, {HTTPS: true})
			result = JSON.parse(res)
		rescue Exception => e
			raise e
		end
	end

	def upload_create(file_name)
		fileSize = File.size(file_name)
		url = "http://#{@upload_server_ip}/gupload/create_file"
		param = {
			'upload_token' => @upload_token,
			'file_size' => fileSize,
			'slice_length' => 1024,
			'ext' => getFileExt(file_name)
		}
		res = post(url, param)
		result = JSON.parse(res)
		if result['error']
			raise result['error'].to_s
		end
		result
	end

	def create_slice
		url = "http://#{@upload_server_ip}/gupload/new_slice"
		param = {'upload_token' => @upload_token}
		res = get(url, param)
		result = JSON.parse(res)
		raise result['error'].to_s if result['error']
		result
	end

	def upload_slice(slice_task_id, offset, length, file_name)
		url =  "http://#{@upload_server_ip}/gupload/upload_slice"
		data = readVideoFile(file_name, offset, length)
		param = {}
		param['upload_token'] = @upload_token
		param['slice_task_id'] = slice_task_id
		param['offset'] = offset
		param['length'] = length
		param['crc'] =  Zlib::crc32(data).to_s(16)
		param['hash'] = Digest::MD5.new.update("#{data}").to_s

		url = URI.parse(url)
		url.query = URI.encode_www_form(param)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url.request_uri)
		request.body = data
		response = http.request(request)
		result =  response.body
		raise result['error'].to_s if result['error']
		result
	end

	#获取文件扩展名
	def getFileExt(file_name) 
		path_parts = File.extname(file_name)
		return path_parts
	end

	#查找文件
	def readVideoFile(filename, offset, length)
		IO.read(filename,length, offset, mode: "rb")
	end

	def commit(uploadServerIp)
		param = {}
		param['access_token'] = @access_token
		param['client_id'] = @client_id
		param['upload_token'] = @upload_token
		param['upload_server_ip'] = uploadServerIp
		url = UPLOAD_COMMIT_URL
		res = get(url, param, {HTTPS: true})
		result = JSON.parse(res)
	end




	# def versionUpdate(verlog)
	# 	file = File.open(verlog, 'r')
	# 	version = file.read.strip
	# 	puts "Your current sdk version is:#{version}"
	# 	param = {
	# 		'client_id'=>@client_id,
	# 		'version' =>version,
	# 		'type' => 'php'
	# 	}
	# 	url = VERSION_UPDATE_URL
	# 	get(url, param)
	# 	file.close
	# end



	#------------------------------------------------------------测试代码----------------


	#普通用户测试  这地方返回的为什么是一个网页
	def getauthcode
		begin
			parameter = {
				"client_id"  => 'd78c97e68901f15e',
				"response_type"=>'code',
				"redirect_uri" =>'https://client.example.com',
			}
			p  parameter
			url = 'https://openapi.youku.com/v2/oauth2/authorize'
			res = get(url, parameter)
			# result = JSON.parse(res)
		rescue Exception => e
			raise e
		end
	end

	#test return {"video_id"=>"XMTMzNjk2MTIyNA==", "upload_token"=>"NzI0NjI2MjVfMDEwMDY0M0FBMjU1Rjk4QkY0QTk5QjJGRTYwMUNENjVBREE1MzItMjFEOS1ERDg3LTkwNUItQURCOThENjZFRjYxXzFfMjBmNmNmNmEyNjgwY2MxM2U1ZmQyMTUyOTMxMDZhYWI=", "upload_server_uri"=>"g3.up.youku.com", "instant_upload_ok"=>"no"} 
	def test_get_upload_token
        file_name = './Public/2015-07-15-test1_vovo.flv'#t
        md5 = Digest::MD5.new
		file_md5 = md5.update "#{file_name}"
		file_size = File.size(file_name)

		uploadInfo={
			"client_id" => 'd78c97e68901f15e',
			"access_token" => 'ac9a447e060d327713ecbd49481f8dcf',
			"title" => 'demo',
			"tags" => 'demo',
			"file_name" => file_name,
			"file_md5" =>file_md5,
			"file_size"=>file_size,
		}
		@client_id ='d78c97e68901f15e'
		@access_token = 'ac9a447e060d327713ecbd49481f8dcf'

		getUploadToken(uploadInfo)
	end

		#test返回空
	def test_upload_create
        file_name = './Public/2015-07-15-test1_vovo.flv'#t
        @upload_server_ip = "g3.up.youku.com"#测试用的
		@upload_token = "NzI0NjI2MjVfMDEwMDY0M0FBMjU1Rjk4QkY0QTk5QjJGRTYwMUNENjVBREE1MzItMjFEOS1ERDg3LTkwNUItQURCOThENjZFRjYxXzFfMjBmNmNmNmEyNjgwY2MxM2U1ZmQyMTUyOTMxMDZhYWI="#t
		uploadCreate(file_name)
	end

	#test 返回 => {"slice_task_id"=>1, "offset"=>0, "length"=>200276, "transferred"=>0, "finished"=>false} 
	def test_create_slice
		# @upload_server_ip = "g3.up.youku.com"#测试用的
		@upload_token="NzI0NjI2MjVfMDEwMDY0M0FBMjU1Rjk4QkY0QTk5QjJGRTYwMUNENjVBREE1MzItMjFEOS1ERDg3LTkwNUItQURCOThENjZFRjYxXzFfMjBmNmNmNmEyNjgwY2MxM2U1ZmQyMTUyOTMxMDZhYWI="#t
		createSlice
	end
	#
	def test_upload_slice
		#测试数据添加
		slice_task_id = 1
		offset = 0
		length = 200276
		file_name = './Public/2015-07-15-test1_vovo.flv'
		@upload_server_ip = "g3.up.youku.com"#测试用的
		@upload_token = "NzI0NjI2MjVfMDEwMDY0M0FBMjU1Rjk4QkY0QTk5QjJGRTYwMUNENjVBREE1MzItMjFEOS1ERDg3LTkwNUItQURCOThENjZFRjYxXzFfMjBmNmNmNmEyNjgwY2MxM2U1ZmQyMTUyOTMxMDZhYWI="
		#测试数据添加结束
		uploadSlice(slice_task_id, offset, length, file_name)
	end
	
	def test_check
		check
	end

	def test_commit
		result = check
		uploadServerIp = result["upload_server_ip"]	
		commit(uploadServerIp)
	end

end
