FactoryGirl.define do
  factory :public_asset, class: Apress::AmazonAssets::PublicAsset do
    trait :with_local_png do
      local { File.new(File.expand_path('../../fixtures/assets/test.png', __FILE__)) }
    end

    trait :with_local_jpg do
      local { File.new(File.expand_path('../../fixtures/assets/test.jpg', __FILE__)) }
    end

    trait :with_local_txt do
      local { File.new(File.expand_path('../../fixtures/assets/test.txt', __FILE__)) }
    end
  end
end
