# coding: utf-8
namespace :amazon do
  namespace :private_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::CleanLocalFilesService.new(PrivateAsset, PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE).call
    end
  end

  namespace :public_assets do
    desc "Ежедневное удаление вложений с нашего сервера"
    task :autoclean => :environment do
      Apress::AmazonAssets::CleanLocalFilesService.new(PublicAsset, PublicAsset::STORAGE_TIME_OF_LOCAL_FILE).call
    end
  end
end
