# coding: utf-8
require 'spec_helper'

describe Apress::AmazonAssets::PrivateAsset do
  it { should have_attached_file(:local) }
  it { should have_attached_file(:remote) }
  it { should validate_attachment_size(:local).less_than(10.megabytes) }
  it { should validate_attachment_size(:remote).less_than(10.megabytes) }
end