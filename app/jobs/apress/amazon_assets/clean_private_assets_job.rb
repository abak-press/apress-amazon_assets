# coding: utf-8

require 'redis-mutex'

module Apress
  module AmazonAssets
    class CleanPrivateAssetsJob
      LOCK_TIMEOUT = 24.hours
      MUTEX_NAME = 'clean_private_amazon_assets'.freeze

      def self.perform
        Redis::Mutex.with_lock(MUTEX_NAME, expire: LOCK_TIMEOUT) do
          CleanLocalFilesService.new(PrivateAsset, PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE).call
        end
      end
    end
  end
end
