json.asset do
  json.partial! 'apress/amazon_assets/api/v1/assets/asset', locals: { asset: @asset }
end
