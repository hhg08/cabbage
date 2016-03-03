module ApplicationHelper
	def getTrackingUrl(hqAdId,hqCreativeId,hqSource='youku',hqEvent=1)
	    sql = "select *,hq_expand_ad.id as aid from hq_expand_ad left join hq_expand_plan on hq_expand_ad.plan=hq_expand_plan.id where hq_expand_ad.id=#{hqAdId}"
	    # result = M('expand_ad')->query($sql);
	    result = ExpandAd.find_by_sql(result)
	    result = result[0]
	    hqClientId = result['company']
	    hqAdId = result['aid']
	    hqGroupId = result['plan']
	    # $hqCreativeId = $result['originality'];
	     return "http://track.hogic.cn/api/ads?hqClientId=#{hqClientId}&hqGroupId=#{hqGroupId}&hqAdId=#{hqAdId}&hqCreativeId=#{hqCreativeId}&hqSource=#{hqSource}&hqEvent=#{hqEvent}"
	end
end
