#encoding:utf-8
class AccountSetsController < ApplicationController
	def index
		@account_sets = AccountSet.all	
	end
	def show
		@account_set = AccountSet.find(params[:id])
	end
	def new
		@account_set = AccountSet.new
	end
	def edit
		@account_set = AccountSet.find(params[:id])
	end
	def create
		@account_set = AccountSet.new(account_set_params)
		if @account_set.save
			redirect_to account_set_path(@account_set), notice:'创建成功！'
		end
	end

	def update
		@account_set = AccountSet.find(params[:id])
		if @account_set.update_attributes(account_set_params)
			redirect_to :action=>:show, notice:'更新成功！'
			#更新成功之后应该调用相应接口去更新相应的文档
		end
	end
	def destroy
		@account_set = AccountSet.find(params[:id])
		@account_set.destroy
		redirect_to account_sets_path, "notice" =>'删除成功！'
	end

	private
  def account_set_params
      params.require(:account_set).permit(:mapping_url, :bid_url, :win_notice_url, :qps, :no_cm_response, :rtb_msg_format, :use_tuserinfo)
    end
end
