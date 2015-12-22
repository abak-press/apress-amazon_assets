# coding: utf-8

module Apress
  module AmazonAssets
    class CleanPublicAssetsJob
      include Resque::Integration

      unique

      def self.execute
        CleanLocalFilesService.new(PublicAsset, PublicAsset::STORAGE_TIME_OF_LOCAL_FILE).call
      end
    end
  end
end
