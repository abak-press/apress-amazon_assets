module Apress
  module AmazonAssets
    module Assets
      module Public
        extend ActiveSupport::Concern

        included do
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
                            s3_protocol: 'https',
                            bucket: Rails.application.config.amazon_assets.fetch(:bucket),
                            path: "public_assets/:id_partition/:basename.:extension",
                            use_timestamp: false,
                            filename_cleaner: ->(filename) { filename },
                            validate_media_type: false

          include ::Apress::AmazonAssets::Assets::Base
        end
      end
    end
  end
end
