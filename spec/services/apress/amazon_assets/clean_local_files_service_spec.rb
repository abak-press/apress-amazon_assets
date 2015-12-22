# coding: utf-8
require 'spec_helper'

describe Apress::AmazonAssets::CleanLocalFilesService do
  context 'delete old assets' do
    let(:old_asset) do
      create :private_asset,
             :with_local_png,
             local_updated_at: (Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE.ago.utc - 1.day)
    end
    let(:not_old_asset) do
      create :private_asset,
             :with_local_png,
             local_updated_at: (Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE.ago.utc + 1.day)
    end

    before do
      allow_any_instance_of(Apress::AmazonAssets::PrivateAsset).to receive(:queue_upload_to_s3)
      VCR.use_cassette 'copy_to_remote', erb: {path: old_asset.local.url.sub(%r{.*/system/}, '')} do
        old_asset.copy_to_remote
      end
      VCR.use_cassette 'copy_to_remote', erb: {path: not_old_asset.local.url.sub(%r{.*/system/}, '')} do
        not_old_asset.copy_to_remote
      end
      described_class.new(
        Apress::AmazonAssets::PrivateAsset,
        Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE
      ).call
    end

    it do
      expect(old_asset.reload.local_file_name).to be_nil
    end

    it do
      expect(not_old_asset.reload.local_file_name).not_to be_nil
    end
  end
end
