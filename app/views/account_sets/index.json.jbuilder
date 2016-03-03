json.array!(@account_set) do |account_set|
  json.extract! account_set, :id
  json.url account_set_url(account_set, format: :json)
end
