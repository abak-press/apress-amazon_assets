# coding: utf-8
class AddFingerprintToAmazonAssets < ActiveRecord::Migration
  def up
    unless connection.column_exists? :amazon_s3_assets, :local_fingerprint
      add_column :amazon_s3_assets, :local_fingerprint, :string

      execute "COMMENT ON COLUMN amazon_s3_assets.local_fingerprint IS 'MD5-отпечаток загруженного файла'"
    end

    unless connection.column_exists? :amazon_s3_public_assets, :local_fingerprint
      add_column :amazon_s3_public_assets, :local_fingerprint, :string

      execute "COMMENT ON COLUMN amazon_s3_public_assets.local_fingerprint IS 'MD5-отпечаток загруженного файла'"
    end
  end

  def down
  end
end
