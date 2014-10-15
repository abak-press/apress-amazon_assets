# coding : utf-8 -*-
class CreateTablesForAmazonAssets < ActiveRecord::Migration
  def self.up
    unless connection.table_exists? 'amazon_s3_assets'
      create_table :amazon_s3_assets do |t|
        t.string :local_file_name
        t.string :local_content_type
        t.integer :local_file_size
        t.datetime :local_updated_at

        t.string :remote_file_name
        t.string :remote_content_type
        t.integer :remote_file_size
        t.datetime :remote_updated_at

        t.integer :attachable_id
        t.string :attachable_type
      end

      add_index :amazon_s3_assets, [:attachable_id, :attachable_type]
    end

    unless connection.table_exists? 'amazon_s3_public_assets'
      create_table :amazon_s3_public_assets do |t|
        t.string :local_file_name
        t.string :local_content_type
        t.integer :local_file_size
        t.datetime :local_updated_at

        t.string :remote_file_name
        t.string :remote_content_type
        t.integer :remote_file_size
        t.datetime :remote_updated_at

        t.integer :attachable_id
        t.string :attachable_type
      end

      add_index :amazon_s3_public_assets, [:attachable_id, :attachable_type], :name => 'index_amazon_s3_p_assets_on_attachable_id_and_attachable_type'
    end
  end

  def self.down
    drop_table :amazon_s3_assets
    drop_table :amazon_s3_public_assets
  end
end
