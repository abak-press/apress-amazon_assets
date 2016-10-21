# Apress::AmazonAssets

[![Build Status](https://drone.railsc.ru/api/badges/abak-press/apress-amazon_assets/status.svg)](https://drone.railsc.ru/abak-press/apress-amazon_assets)
[![Code Climate](https://codeclimate.com/repos/543e65e6e30ba041d401e98d/badges/fd82abeaab68a66be573/gpa.svg)](https://codeclimate.com/repos/543e65e6e30ba041d401e98d/feed)

Гем позволяет хранить файлы на Amazon S3.

Содержит в себе две модели: `Apress::AmazonAssets::PrivateAsset` и `Apress::AmazonAssets::PublicAsset`.

Отличие между ними в том, что в публичной файлы можно просматривать по прямой ссылке, а в другой только секретной.

## Installation

Add this line to your application's Gemfile:

    gem 'apress-amazon_assets'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apress-amazon_assets

## Usage

В проекте необходимо создать конфиг config/amazon_s3.yml

```yml
production:
  bucket: amazon_assets
  access_key_id: AKIAJR44XLNRQVCSDJTQ
  secret_access_key: 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
```

Модель, хранящая в себе приложенные файлы app/models/name.rb

```ruby
class Name < ActiveRecord::Base
  has_many :attachments, :class_name => "Apress::AmazonAssets::PrivateAsset", :as => :attachable, :dependent => :destroy, :limit => 3
end
```

Вначале файлы загружаются локально на сервер и потом через resque загружаются на амазон. Очередь resque называется `upload`.

В проектном crontab необходимо вызывать автоочистку через rake задачу

```
rake amazon:private_assets:autoclean
rake amazon:public_assets:autoclean
```

## Gem Releasing

1. должен быть настроен git remote upstream и должны быть права на push
1. git checkout master
2. git pull upstream master
3. правим версию гема в файле VERSION в корне гема. (читаем правила версионирования http://semver.org/)
4. apress-gem release --version 0.0.1

## Contributing

1. Fork it ( https://github.com/[my-github-username]/apress-amazon_assets/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
