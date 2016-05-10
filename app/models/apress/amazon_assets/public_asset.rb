# coding: utf-8
module Apress
  module AmazonAssets
    class PublicAsset < ActiveRecord::Base
      self.table_name = 'amazon_s3_public_assets'

      include ::Apress::AmazonAssets::Assets::Public
    end
  end
end
