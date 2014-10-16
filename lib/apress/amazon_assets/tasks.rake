# coding: utf-8
namespace :amazon do
  namespace :private_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::PrivateAsset.
        where("remote_file_name IS NOT NULL AND local_file_name IS NOT NULL AND local_updated_at < ?",
              Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE.ago.utc).
        find_each do |asset|
          asset.local = nil
          asset.save(:validate => false)
        end
    end
  end

  namespace :public_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::PublicAsset.
        where("remote_file_name IS NOT NULL AND local_file_name IS NOT NULL AND local_updated_at < ?",
              Apress::AmazonAssets::PublicAsset::STORAGE_TIME_OF_LOCAL_FILE.ago.utc).
        find_each do |asset|
        asset.local = nil
        asset.save(:validate => false)
      end
    end
  end
end
