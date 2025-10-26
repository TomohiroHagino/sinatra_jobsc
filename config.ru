require 'bundler/setup'
Bundler.require

require_relative 'config/database'
require_relative 'config/base_application'

# 1) Domain（値オブジェクト/エンティティ/サービスなど）
Dir[File.join(__dir__, 'app', 'domain', '**', '*.rb')].sort.each { |f| require f }

# 2) Infrastructure の ActiveRecord モデル（←ココを追加）
Dir[File.join(__dir__, 'app', 'infrastructure', 'models', '**', '*.rb')].sort.each { |f| require f }

# 3) リポジトリ（ARモデルに依存するのでモデルの後）
Dir[File.join(__dir__, 'app', 'infrastructure', 'repositories', '**', '*.rb')].sort.each { |f| require f }

# 4) 外部サービス（必要に応じて順序はサービスの前後どちらでも）
Dir[File.join(__dir__, 'app', 'infrastructure', 'external_services', '**', '*.rb')].sort.each { |f| require f }

Dir[File.join(__dir__, 'app', 'application', 'use_cases', '**', '*.rb')].sort.each { |f| require f }

Dir[File.join(__dir__, 'app', 'application', 'services', '**', '*.rb')].sort.each { |f| require f }

Dir[File.join(__dir__, 'app', 'presentation', 'controllers', '**', '*.rb')].sort.each { |f| require f }

# ルーティング
require_relative 'config/routes'

# Rackアプリ起動
run App
