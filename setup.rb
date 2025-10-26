#!/usr/bin/env ruby

require 'bundler/setup'
require_relative 'config/database'

# Load all domain models
Dir[File.join(__dir__, 'app', 'domain', '**', '*.rb')].each { |file| require file }

puts "データベース接続テスト..."
puts "接続状態: #{ActiveRecord::Base.connected?}"

puts "\nテーブル確認..."
if ActiveRecord::Base.connection.table_exists?('saved_jobs')
  puts "✅ saved_jobs テーブルが存在します"
  count = Domain::JobScraper::SavedJob.count
  puts "保存された求人数: #{count}"
else
  puts "❌ saved_jobs テーブルが存在しません"
end

puts "\nサンプルデータの作成..."
sample_job = Domain::JobScraper::SavedJob.create!(
  title: "Rails エンジニア募集",
  company_name: "サンプル株式会社",
  salary_min: 100,
  salary_max: 150,
  location: "東京都",
  remote_work: true,
  job_type: "正社員",
  description: "Rails を使ったWebアプリケーション開発を行います。",
  url: "https://example.com/job/1",
  source_site: "Findy"
)

puts "✅ サンプルデータを作成しました (ID: #{sample_job.id})"

puts "\nアプリケーションの起動準備完了！"
puts "以下のコマンドでアプリケーションを起動してください："
puts "bundle exec rackup"
