require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test? #開発とテスト環境では今まで通りにfileに
    config.storage= :file
  elsif Rails.env.production? #本番はS3に保存するようにしている
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.credentials.aws[:access_key_id],
      aws_secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      region: 'ap-northeast-1'
    }

    config.fog_directory  = 'freemarket71d'
    config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/freemarket71d'
  end
end