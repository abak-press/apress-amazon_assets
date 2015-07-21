# coding: utf-8
require 'spec_helper'

require_relative 'concerns/base_asset_shared_examples'

describe Apress::AmazonAssets::PublicAsset do
  it_behaves_like 'base asset', :public_asset

  subject { create :public_asset }

  describe 'local' do
    it { expect(subject).to have_attached_file(:local) }

    context 'when assigned' do
      let(:file) { File.new('spec/fixtures/assets/test.txt') }

      let(:expected_path) { %r{#{Rails.root}/public/system/public_assets/.*/[0-9a-f]{4}__test\.txt} }
      let(:expected_url) { %r{/system/public_assets/.*/[0-9a-f]{4}__test\.txt} }

      before { subject.local = file }

      Then { expect(subject.local).to be_present }
      And  { expect(subject.local.path).to match expected_path }
      And  { expect(subject.local.url).to match expected_url }
    end
  end

  describe 'remote' do
    it { expect(subject).to have_attached_file(:remote) }

    context 'when assigned' do
      let(:file) { File.new('spec/fixtures/assets/test.jpg') }

      let(:expected_path) { %r{public_assets/.*/test\.jpg} }
      let(:expected_url) { %r{http://s3\.amazonaws\.com/amazon_assets_test/public_assets/.*/test\.jpg} }

      before { subject.remote = file }

      Then { expect(subject.remote).to be_present }
      And  { expect(subject.remote.path).to match expected_path }
      And  { expect(subject.remote.url).to match expected_url }
    end
  end
end
