require 'active_record'
require 'sqlite3'

# データベースディレクトリを作成
Dir.mkdir('db') unless Dir.exist?('db')

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

# マイグレーションファイルを読み込み
Dir[File.join(__dir__, '..', 'db', 'migrate', '*.rb')].each { |file| require file }

# テーブルが存在しない場合は作成
unless ActiveRecord::Base.connection.table_exists?('saved_jobs')
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

    add_index :saved_jobs, :source_site
    add_index :saved_jobs, :is_active
    add_index :saved_jobs, :remote_work
    add_index :saved_jobs, [:salary_min, :salary_max]
  end
end