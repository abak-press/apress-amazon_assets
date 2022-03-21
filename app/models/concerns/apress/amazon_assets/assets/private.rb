module Apress
  module AmazonAssets
    module Assets
      module Private
        extend ActiveSupport::Concern

        ENDPOINT = 's3.yandexcloud.net'
        S3_BUCKET = Rails.application.config.amazon_assets.fetch(:bucket)

        included do
          has_attached_file :local,
                            path: ":rails_root/public/system/assets/:id_partition/:basename.:extension",
                            url: "#{ActionController::Base.asset_host}/system/assets/:id_partition/:basename.:extension",
                            use_timestamp: false,
                            filename_cleaner: ->(filename) { filename },
                            validate_media_type: false

          has_attached_file :remote,
                            storage: :s3,
                            s3_credentials: "#{Rails.root}/config/amazon_s3.yml",
                            s3_permissions: 'authenticated-read',
                            s3_protocol: 'https',
                            bucket: S3_BUCKET,
                            path: "assets/:id_partition/:basename.:extension",
                            s3_host_name: ENDPOINT,
                            url: "https://#{ENDPOINT}/#{S3_BUCKET}/assets/:id_partition/:basename.:extension",
                            use_timestamp: false,
                            filename_cleaner: ->(filename) { filename },
                            validate_media_type: false

          include ::Apress::AmazonAssets::Assets::Base
        end
      end
    end
  end
end
