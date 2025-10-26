FactoryBot.define do
  factory :saved_job, class: 'Infrastructure::Model::SavedJob' do
    title { "Railsエンジニア募集" }
    company_name { "テスト株式会社" }
    salary_min { 80 }
    salary_max { 120 }
    location { "東京都" }
    remote_work { true }
    job_type { "正社員" }
    description { "Ruby on Rails を使用したWebアプリケーション開発" }
    url { "https://example.com/job/1" }
    source_site { "テストサイト" }
    is_active { true }

    trait :inactive do
      is_active { false }
    end

    trait :no_remote do
      remote_work { false }
    end

    trait :high_salary do
      salary_min { 100 }
      salary_max { 150 }
    end
  end
end

