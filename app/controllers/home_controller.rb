class HomeController < ApplicationController
  # BUG TODO change client id and callback url to project config
	YOUKU_FILE_UPLOAD_CLIENT_ID = '367e496b1ea3a717'
 	YOUKU_FILE_UPLOAD_CLIENT_SECRET = 'ffdc8f076ad603c574f9f38a30e38b0d'

  # before_action :authenticate_user!

  def index
    @users = User.all
  end
  def get_access_token
    client_id = YOUKU_FILE_UPLOAD_CLIENT_ID # Youku OpenAPI client_id
    client_secret = YOUKU_FILE_UPLOAD_CLIENT_SECRET #Youku OpenAPI client_secret
    jump = CGI.escape 'http://dsp.cn/Admin/Youku/getYoukuAccesstokenBack'
    url = "https://openapi.youku.com/v2/oauth2/authorize?client_id=#{client_id}&response_type=code&redirect_uri=#{jump}&state=xyz"
    render text: "<script type='text/javascript'>location.href='#{url}';</script>";
  end


  def access_token_callback
    url = 'https://openapi.youku.com/v2/oauth2/token'
	  # jump = 'http://dsp.hogic.cn/Admin/Youku/getYoukuAccesstokenBack'
	  jump = 'http://dsp.cn/Admin/Youku/getYoukuAccesstokenBack'
    formvars = {}
    formvars['client_id'] = YOUKU_FILE_UPLOAD_CLIENT_ID
    formvars['client_secret'] = YOUKU_FILE_UPLOAD_CLIENT_SECRET
    formvars['grant_type'] = 'authorization_code'
    formvars['code'] = params[:code]
    formvars['redirect_uri'] = jump

    url = URI(url)
    http = Net::HTTP.new(url.hostname, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
    req = Net::HTTP::Post.new(url.request_uri)
    req.form_data = formvars
    resp = http.request(req)
    puts "response body => " + resp.body 
  	json_obj = JSON.parse(resp.body)
  	render text: json_obj.to_s
  end

  #每一分钟调用腾讯url
  def tencent_operation
    begin
      #腾讯素材定时上传 
      TencentAdList.tencent_ad_material_upload
      #定时更新Tencent上传素材的状态
      TencentAdList.check_tencent_status

    rescue Exception => e
      raise e
    end
    render text: 'ok'
  end
  #爱奇艺素材
  def iqiyi_origina_operation
    begin
      AiQiYiUpload.aiqiyi_ad_material_upload
      AiQiYiUpload.check_aiqiyi_status
    rescue Exception => e
      raise e
    end
    render text: 'ok'
  end
  #爱奇艺广告主
  def iqiyi_advertiser_operation
    begin
      AiQiYiUpload.upload_advertiser_info
      AiQiYiUpload.check_adver_status
    rescue Exception => e
      raise e
    end
    render text: 'ok'
  end
end