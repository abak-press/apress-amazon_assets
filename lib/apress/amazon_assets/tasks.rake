# coding: utf-8
namespace :amazon do
  namespace :private_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::CleanLocalFilesService.new(
        Apress::AmazonAssets::PrivateAsset,
        Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE
      ).call
    end
  end

  namespace :public_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::CleanLocalFilesService.new(
        Apress::AmazonAssets::PublicAsset,
        Apress::AmazonAssets::PublicAsset::STORAGE_TIME_OF_LOCAL_FILE
      ).call
    end
  end
end
