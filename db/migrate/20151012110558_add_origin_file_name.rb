class AddOriginFileName < ActiveRecord::Migration
  TABLES = [:amazon_s3_assets, :amazon_s3_public_assets]

  def up
    TABLES.each {|t| add_column t, :origin_file_name, :string }
  end

  def down
    TABLES.each {|t| remove_column t, :origin_file_name }
  end
end
