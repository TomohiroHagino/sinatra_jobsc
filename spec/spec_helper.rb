ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
Bundler.require

require 'rack/test'
require 'rspec'
require 'factory_bot'
require 'database_cleaner/active_record'

# アプリケーションの設定ファイルを読み込み
require_relative '../config/database'
require_relative '../config/base_application'

# 1) Domain層（値オブジェクト/エンティティ/サービスなど）
Dir[File.join(__dir__, '../app/domain/**/*.rb')].sort.each { |f| require f }

# 2) Infrastructure の ActiveRecord モデル
Dir[File.join(__dir__, '../app/infrastructure/models/**/*.rb')].sort.each { |f| require f }

# 3) リポジトリ（ARモデルに依存するのでモデルの後）
Dir[File.join(__dir__, '../app/infrastructure/repositories/**/*.rb')].sort.each { |f| require f }

# 4) 外部サービス
Dir[File.join(__dir__, '../app/infrastructure/external_services/**/*.rb')].sort.each { |f| require f }

# 5) Application層
Dir[File.join(__dir__, '../app/application/use_cases/**/*.rb')].sort.each { |f| require f }
Dir[File.join(__dir__, '../app/application/services/**/*.rb')].sort.each { |f| require f }

# 6) Presentation層
Dir[File.join(__dir__, '../app/presentation/controllers/**/*.rb')].sort.each { |f| require f }

# ルーティング
require_relative '../config/routes'

RSpec.configure do |config|
  # Rack::Testのメソッドを使用可能にする
  config.include Rack::Test::Methods

  # FactoryBotの設定
  config.include FactoryBot::Syntax::Methods

  # FactoryBotのファクトリディレクトリを設定
  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # データベースクリーナーの設定
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # テスト用データベースの設定
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'db/test.sqlite3'
    )
    
    # テーブルが存在しない場合は作成
    unless ActiveRecord::Base.connection.table_exists?(:saved_jobs)
      ActiveRecord::Schema.define do
        create_table :saved_jobs do |t|
          t.string :title, null: false
          t.string :company_name, null: false
          t.integer :salary_min
          t.integer :salary_max
          t.string :location
          t.boolean :remote_work, default: false
          t.string :job_type
          t.text :description
          t.string :url, null: false
          t.string :source_site, null: false
          t.boolean :is_active, default: true
          t.timestamps
        end
      end
    end
  end

  # RSpecの設定
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

