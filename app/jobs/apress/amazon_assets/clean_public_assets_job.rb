# coding: utf-8

require 'redis-mutex'

module Apress
  module AmazonAssets
    class CleanPublicAssetsJob
      LOCK_TIMEOUT = 24.hours
      MUTEX_NAME = 'clean_public_amazon_assets'.freeze

      def self.perform
        Redis::Mutex.with_lock(MUTEX_NAME, expire: LOCK_TIMEOUT) do
          CleanLocalFilesService.new(PublicAsset, PublicAsset::STORAGE_TIME_OF_LOCAL_FILE).call
        end
      end
    end
  end
end
