json.(asset, :id, :origin_file_name, :file_size, :file_content_type)

json.file asset.file.to_s
