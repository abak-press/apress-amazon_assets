module Apress
  module AmazonAssets
    module Assets
      module Public
        extend ActiveSupport::Concern

        included do
          S3_BUCKET = "#{APP_NAME}#{"_#{Rails.env}" unless Rails.env.production?}".freeze

          has_attached_file :local,
                            path: ":rails_root/public/system/public_assets/:id_partition/:basename.:extension",
                            url: "#{ActionController::Base.asset_host}/system/public_assets/:id_partition/:basename.:extension",
                            use_timestamp: false,
                            filename_cleaner: ->(filename) { filename },
                            validate_media_type: false

          has_attached_file :remote,
                            storage: :s3,
                            s3_credentials: "#{Rails.root}/config/amazon_s3.yml",
                            s3_permissions: :public_read,
                            s3_protocol: 'http',
                            bucket: S3_BUCKET,
                            path: "public_assets/:id_partition/:basename.:extension",
                            url: "https://s3.amazonaws.com/#{S3_BUCKET}/public_assets/:id_partition/:basename.:extension",
                            use_timestamp: false,
                            filename_cleaner: ->(filename) { filename },
                            validate_media_type: false

          include ::Apress::AmazonAssets::Assets::Base
        end
      end
    end
  end
end
