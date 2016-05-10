# coding: utf-8
module Apress
  module AmazonAssets
    class PrivateAsset < ActiveRecord::Base
      self.table_name = 'amazon_s3_assets'

      include ::Apress::AmazonAssets::Assets::Private
    end
  end
end
