
module DSP
  module API
    class TxUploadAdsInfo
      if Rails.env.to_s == "production"
        AUTH = {dsp_id: 10083, token: '3cbbe8970fb9daeaef5b697f4717fe40'}
        ADX_URL = 'http://open.adx.qq.com'
      else
        AUTH = {dsp_id: 190, token: '73553e669b7270a4934706f76a99ad36'}
        ADX_URL = 'http://opentest.adx.qq.com'
      end
      class << self
        def upload_material(options = {})
          target_url = "#{ADX_URL}/order/sync"
          order_info = [{
                          "dsp_order_id"=> "#{options[:dsp_order_id]}",
                          "client_name"=> "#{options[:client_name]}",
                          "file_info"=> [{
                          "file_url"=> "#{options[:file_url]}" 
                          }],
                          "targeting_url"=> "#{options[:targeting_url]}" ,
                        "monitor_url"=> options[:monitor_url]
                      }].to_json
          body = {order_info: order_info}.merge(AUTH)
          req = HTTParty.post(target_url, body: body).body
          JSON.parse(req)
        end
        #更新状态
        def check_status(*dsp_order_id_info)
          target_url = "#{ADX_URL}/order/getstatus"
          body = {dsp_order_id_info: dsp_order_id_info.to_s}.merge(AUTH)
          req = HTTParty.post(target_url, body: body, timeout:600).body
          JSON.parse(req)
        end
      end
    end
  end
end
