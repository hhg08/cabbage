ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

describe AiQiYiUpload do
  context ".check_aiqiyi_status" do
	    before(:each) do
	    end
	    it "should return true" do
			expect(AiQiYiUpload.check_aiqiyi_status).to be_truthy
	    end
	end
end